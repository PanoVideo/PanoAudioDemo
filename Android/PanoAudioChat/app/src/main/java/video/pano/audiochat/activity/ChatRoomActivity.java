package video.pano.audiochat.activity;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.drawable.PaintDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatCheckBox;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.gson.Gson;
import com.pano.rtc.api.Constants;
import com.pano.rtc.api.RtcAudioIndication;
import com.pano.rtc.api.RtcAudioMixingMgr;
import com.pano.rtc.api.RtcChannelConfig;
import com.pano.rtc.api.RtcEngine;
import com.pano.rtc.api.RtcMessageService;
import com.pano.rtc.api.model.RtcAudioLevel;
import com.pano.rtc.api.model.RtcPropertyAction;

import java.lang.ref.WeakReference;
import java.util.List;

import video.pano.audiochat.R;
import video.pano.audiochat.adapter.ChatMsgAdapter;
import video.pano.audiochat.adapter.MicApplyAdapter;
import video.pano.audiochat.adapter.UserMicStatusAdapter;
import video.pano.audiochat.rtc.PanoEvent;
import video.pano.audiochat.rtc.PanoRtcEngine;
import video.pano.audiochat.rtc.PanoRtcMgr;
import video.pano.audiochat.rtc.PanoTypeConstant;
import video.pano.audiochat.rtc.PanoUserMgr;
import video.pano.audiochat.rtc.data.BaseMessage;
import video.pano.audiochat.rtc.data.PanoCmdMessage;
import video.pano.audiochat.rtc.data.PanoCmdUser;
import video.pano.audiochat.rtc.data.PanoMsgFactory;
import video.pano.audiochat.rtc.data.PanoNormalMessage;
import video.pano.audiochat.rtc.data.PanoUser;
import video.pano.audiochat.utils.AvatorUtil;
import video.pano.audiochat.view.EarMonitorSettingView;
import video.pano.audiochat.view.MicApplyView;
import video.pano.audiochat.view.MicInviteView;
import video.pano.audiochat.view.MusicSettingView;
import video.pano.audiochat.view.WaveImageView;

import static video.pano.audiochat.rtc.PanoTypeConstant.ALL_MIC_KEY;

public class ChatRoomActivity extends AppCompatActivity implements PanoEvent, RtcAudioMixingMgr.Callback,
        RtcAudioIndication, RtcMessageService.Callback, PanoRtcMgr.BgmCallback,
        MicApplyAdapter.DealApplyCallback, UserMicStatusAdapter.OnItemClickListener,
        MicInviteView.MicInviteCallback, EarMonitorSettingView.EarMonitorSettingCallback {

    private static final String TAG = "ChatRoomActivity";
    private static final String ROOM_ID = "room_id";
    private static final String USER_NAME = "user_name";
    private static final String USER_ID = "user_id";
    private static final String TOKEN = "token";
    private static final String IS_HOST = "is_host";
    private static final String HOST_USER_ID = "host_user_id";

    private static final long TIME_OUT_DELAY = 30 * 1000 ;

    private static final int REJECT_TIME_OUT = 100 ;
    private static final int REJECT_SELF_TIME_OUT = 200 ;
    private static final int INVITE_TIME_OUT = 300 ;

    private WaveImageView mHostPhoto;
    private TextView mHostName;
    private UserMicStatusAdapter mUserMicStatusAdapter;
    private View mRootView;
    private View mBottomToolContainer;
    private EditText mSendMsgEdit;
    private TextView mPeopleOnlineTv;
    private TextView mSendMsgTv;

    private TextView mRoomNoticeBadge;
    private ImageView mRoomNoticeIcon;
    private ImageView mBgmPlayIcon;
    private AppCompatCheckBox mMuteCheckBox;
    private ImageView mEarMonitorIcon;

    private MusicSettingView mMusicSettingView;
    private MicApplyView mMicApplyView;
    private MicInviteView mMicInviteView;
    private PopupWindow mMusicSettingsPopup;
    private PopupWindow mMicApplyPopup;
    private PopupWindow mMicApplyWaitingPopup;
    private PopupWindow mMicInvitePopup;
    private PopupWindow mEarMonitorPopup;
    private Dialog mInviteDialog;

    private ChatMsgAdapter mChatMsgAdapter;

    private String mRoomId;
    private String mUserName;
    private long mUserId;
    private String mToken;
    private boolean mIsHost;
    private boolean mIsFirstLoad;

    private long mHostUserId;
    private boolean mDumpAudio = false;

    private Message mSendMessage ;
    private RtcEngine mRtcEngine;
    private RtcMessageService mRtcMessageService;
    private Constants.MessageServiceState mMessageServiceState = Constants.MessageServiceState.Unavailable;
    private final Gson mGson = new Gson();
    private final ChatHandler cHandler = new ChatHandler(this);

    private static final class ChatHandler extends Handler {
        WeakReference<ChatRoomActivity> chatWeakReference;

        ChatHandler(ChatRoomActivity activity) {
            chatWeakReference = new WeakReference<>(activity);
        }

        @Override
        public void handleMessage(@NonNull Message msg) {
            super.handleMessage(msg);
            final ChatRoomActivity activity = chatWeakReference.get();
            if (activity == null) {
                return;
            }
            switch (msg.what){
                case REJECT_TIME_OUT:
                    if((activity.mRoomNoticeIcon == null || activity.mRoomNoticeIcon.getVisibility() == View.GONE)
                            && (activity.mMicApplyPopup == null || !activity.mMicApplyPopup.isShowing())){
                        return ;
                    }
                    PanoCmdUser user1 = (PanoCmdUser) msg.obj;
                    PanoRtcEngine.getInstance().getMessageService().sendMessage(user1.userId,PanoMsgFactory.declineApplyMsg(PanoTypeConstant.REASON_TIMEOUT,user1));
                    PanoUserMgr.getIns().refreshUserStatus(user1.userId, PanoTypeConstant.NONE);
                    PanoUserMgr.getIns().removeMicApplyUser(user1.userId);
                    activity.onDeclineMicApply(user1);
                    break;
                case REJECT_SELF_TIME_OUT:
                    if(activity.mMicApplyWaitingPopup == null || !activity.mMicApplyWaitingPopup.isShowing()){
                        return ;
                    }
                    PanoCmdUser user2 = (PanoCmdUser) msg.obj;
                    activity.mUserMicStatusAdapter.refreshUserStatus(user2.userId,PanoTypeConstant.NONE);
                    Toast.makeText(activity,
                            R.string.room_user_apply_reject_toast, Toast.LENGTH_SHORT).show();
                    if (activity.mMicApplyWaitingPopup.isShowing()) {
                        activity.mMicApplyWaitingPopup.dismiss();
                    }
                    break;
                case INVITE_TIME_OUT:
                    PanoCmdUser user3 = (PanoCmdUser) msg.obj;
                    if(activity.mInviteDialog != null && activity.mInviteDialog.isShowing()){
                        activity.mInviteDialog.dismiss();
                    }
                    PanoRtcEngine.getInstance().getMessageService().sendMessage(activity.mHostUserId,
                            PanoMsgFactory.rejectInviteMsg(PanoTypeConstant.REASON_TIMEOUT,user3));
                    break;
            }
        }
    }

    public static void start(Activity activity, String roomId, String userName, long userId,
                             String token, boolean isHost, String hostUserId) {
        Intent intent = new Intent(activity, ChatRoomActivity.class);
        intent.putExtra(ROOM_ID, roomId);
        intent.putExtra(USER_NAME, userName);
        intent.putExtra(USER_ID, userId);
        intent.putExtra(TOKEN, token);
        intent.putExtra(IS_HOST, isHost);
        intent.putExtra(HOST_USER_ID, hostUserId);
        activity.startActivity(intent);
    }

    private boolean keyboardIsVisible(View rootView) {
        final int softKeyboardHeight = 100;
        Rect r = new Rect();
        rootView.getWindowVisibleDisplayFrame(r);
        DisplayMetrics dm = rootView.getResources().getDisplayMetrics();
        int heightDiff = rootView.getBottom() - r.bottom;
        return heightDiff > softKeyboardHeight * dm.density;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);

        setContentView(R.layout.activity_chat_room);

        Intent intent = getIntent();
        mRoomId = intent.getStringExtra(ROOM_ID);
        mUserName = intent.getStringExtra(USER_NAME);
        mUserId = intent.getLongExtra(USER_ID, 0);
        mToken = intent.getStringExtra(TOKEN);
        mIsHost = intent.getBooleanExtra(IS_HOST, false);
        String hostUserId = intent.getStringExtra(HOST_USER_ID);

        mIsFirstLoad = true;

        if (!TextUtils.isEmpty(hostUserId)) {
            try {
                mHostUserId = Long.parseLong(hostUserId);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        initViews();

        PanoRtcMgr.getInstance().addPanoEventListener(this);
        mRtcEngine = PanoRtcEngine.getInstance();
        mRtcEngine.setAudioIndication(this);
        mRtcEngine.getAudioMixingMgr().setCallback(this);
        mRtcMessageService = mRtcEngine.getMessageService();
        mRtcMessageService.setCallback(this);

        if(mIsHost){PanoUserMgr.getIns().initMicList();}
        enterRoom();
    }

    private void initViews() {

        mRootView = ((ViewGroup) findViewById(android.R.id.content)).getChildAt(0);
        mRootView.getViewTreeObserver().addOnGlobalLayoutListener(
                () -> refreshBottomUI(keyboardIsVisible(mRootView))
        );

        initTitleViews();
        initHeadView();
        initChatMsgListView();
        initUserMicStatusView();
        initBgmView();
        initBottomViews();
    }

    private void initTitleViews() {
        mRoomNoticeIcon = findViewById(R.id.room_notice);
        mRoomNoticeBadge = findViewById(R.id.notice_badge_num);
        TextView roomId = findViewById(R.id.room_id);

        mPeopleOnlineTv = findViewById(R.id.people_online);
        roomId.setText(mRoomId);

        if (mIsHost) {
            mMicApplyView = new MicApplyView(this);
            mMicApplyView.setDealApplyCallback(this);
            mMicInviteView = new MicInviteView(this);
            mMicInviteView.setMicInviteCallback(this);
        }
    }

    private void initHeadView() {
        mHostPhoto = findViewById(R.id.host_photo);
        mHostName = findViewById(R.id.host_name);
        if(mIsHost){
            mHostPhoto.setImageResource(AvatorUtil.getAvatorResByUserId(mHostUserId));
            mHostName.setText(mUserName);
        }
    }

    private void initChatMsgListView() {
        ListView chatMsgList = findViewById(R.id.chat_msg_list);
        mChatMsgAdapter = new ChatMsgAdapter(this);
        chatMsgList.setAdapter(mChatMsgAdapter);
        chatMsgList.setTranscriptMode(ListView.TRANSCRIPT_MODE_ALWAYS_SCROLL);
    }

    private void initUserMicStatusView() {
        RecyclerView userMicStatusView = findViewById(R.id.user_mic_status_view);
        userMicStatusView.setLayoutManager(new GridLayoutManager(this, 4) {
            @Override
            public boolean canScrollVertically() {
                return false;
            }
        });
        mUserMicStatusAdapter = new UserMicStatusAdapter(this,mIsHost);
        mUserMicStatusAdapter.initData();
        mUserMicStatusAdapter.setOnItemClickListener(this);
        userMicStatusView.setAdapter(mUserMicStatusAdapter);
    }

    private void initBgmView() {
        if (mIsHost) {
            PanoRtcMgr.getInstance().setBgmCallback(this);
            View mBgmView = findViewById(R.id.music_tool_layout);
            mBgmView.setVisibility(View.VISIBLE);
            mMusicSettingView = new MusicSettingView(this);
            findViewById(R.id.music_res).setOnClickListener(v -> showBgmSettingsPopup());
            mBgmPlayIcon = findViewById(R.id.music_play);
            mBgmPlayIcon.setOnClickListener(v -> {
                if (PanoRtcMgr.getInstance().isPlayingBgm()) {
                    PanoRtcMgr.getInstance().pauseBgm();
                } else {
                    PanoRtcMgr.getInstance().playBgm();
                }

            });
            findViewById(R.id.music_next).setOnClickListener(v -> PanoRtcMgr.getInstance().playNextBgm());
        }
    }

    private void initBottomViews() {
        mSendMsgEdit = findViewById(R.id.send_text_edit);
        mSendMsgTv = findViewById(R.id.send_msg);
        mBottomToolContainer = findViewById(R.id.tool_container);
        mSendMsgTv.setOnClickListener(v -> sendMsg());

        AppCompatCheckBox loudspeakerCheckBox = findViewById(R.id.loud_speaker);
        mMuteCheckBox = findViewById(R.id.mute);
        mEarMonitorIcon = findViewById(R.id.ear_monitor);

        if (mIsHost) {
            mMuteCheckBox.setVisibility(View.VISIBLE);
            mEarMonitorIcon.setVisibility(View.VISIBLE);
        } else {
            mMuteCheckBox.setVisibility(View.GONE);
            mEarMonitorIcon.setVisibility(View.GONE);
        }

        loudspeakerCheckBox.setOnCheckedChangeListener(
                (buttonView, isChecked) -> mRtcEngine.setLoudspeakerStatus(!isChecked));

        mMuteCheckBox.setOnCheckedChangeListener((buttonView, isChecked) -> {

            int micStatus = mUserMicStatusAdapter.getItemStatus(mUserId);
            if(!isChecked && micStatus == PanoTypeConstant.MUTE){
                Toast.makeText(this,R.string.room_anchor_forbids_speak,Toast.LENGTH_SHORT).show();
                buttonView.setChecked(true);
                return ;
            }

            if (isChecked) {
                mRtcEngine.muteAudio();
                notifyMicStatusAdapter(mUserId, PanoTypeConstant.MUTE);
            } else {
                mRtcEngine.unmuteAudio();
                notifyMicStatusAdapter(mUserId, PanoTypeConstant.DONE);
            }
        });

        mEarMonitorIcon.setOnClickListener(v -> showEarMonitorPopup());

    }

    private void refreshBottomUI(boolean isKeyboardVisible) {
        if (isKeyboardVisible) {
            mSendMsgTv.setVisibility(View.VISIBLE);
            mBottomToolContainer.setVisibility(View.GONE);
        } else {
            mSendMsgTv.setVisibility(View.GONE);
            mBottomToolContainer.setVisibility(View.VISIBLE);
        }
    }

    private void refreshNoticeView() {
        if (mIsHost) {
            if (PanoUserMgr.getIns().getMicApplyCount() > 0) {
                mRoomNoticeIcon.setVisibility(View.VISIBLE);
                mRoomNoticeBadge.setVisibility(View.VISIBLE);
                mRoomNoticeBadge.setText(String.valueOf(PanoUserMgr.getIns().getMicApplyCount()));
                mMicApplyView.refresh();
            } else {
                mRoomNoticeIcon.setVisibility(View.GONE);
                mRoomNoticeBadge.setVisibility(View.GONE);
                if (mMicApplyPopup != null && mMicApplyPopup.isShowing()) {
                    mMicApplyPopup.dismiss();
                }
            }
        }
    }

    private void showBgmSettingsPopup() {
        if (mMusicSettingsPopup == null) {
            mMusicSettingsPopup = new PopupWindow(mMusicSettingView,
                    ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            mMusicSettingsPopup.setBackgroundDrawable(new PaintDrawable(Color.TRANSPARENT));
            mMusicSettingsPopup.setOutsideTouchable(true);
        }
        if (!mMusicSettingsPopup.isShowing()) {
            mMusicSettingsPopup.showAtLocation(mHostPhoto, Gravity.BOTTOM, 0, 0);
        }
    }

    private void showEarMonitorPopup() {
        if (mEarMonitorPopup == null) {
            EarMonitorSettingView earMonitorSettingView = new EarMonitorSettingView(this);
            earMonitorSettingView.setEarMonitorSettingCallback(this);
            mEarMonitorPopup = new PopupWindow(earMonitorSettingView,
                    ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            mEarMonitorPopup.setBackgroundDrawable(new PaintDrawable(Color.TRANSPARENT));
            mEarMonitorPopup.setOutsideTouchable(true);
        }
        if (!mEarMonitorPopup.isShowing()) {
            mEarMonitorPopup.showAtLocation(mEarMonitorIcon, Gravity.BOTTOM, 0, 0);
        }
    }

    public void onClickNotice(View view) {
        if (mMicApplyPopup == null) {
            mMicApplyPopup = new PopupWindow(mMicApplyView,
                    ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            mMicApplyPopup.setBackgroundDrawable(new PaintDrawable(Color.TRANSPARENT));
            mMicApplyPopup.setOutsideTouchable(true);
        }
        if (!mMicApplyPopup.isShowing()) {
            mMicApplyView.refresh();
            mMicApplyPopup.showAtLocation(view, Gravity.TOP, 0, 0);
        }
    }

    public void onClickSetting(View view) {
        SettingActivity.start(this);
    }

    public void onClickExit(View view) {
        onBack();
    }

    private void onBack() {
        int resId = mIsHost ? R.string.room_exit_and_disband : R.string.room_leave;
        Dialog dialog = new AlertDialog.Builder(this)
                .setTitle(resId)
                .setPositiveButton(R.string.ok, (dialog1, which) -> finish())
                .setNegativeButton(R.string.cancel, null)
                .create();
        dialog.show();
    }

    private void enterRoom() {
        RtcChannelConfig config = new RtcChannelConfig();
        config.userName = mUserName;
        config.mode_1v1 = false;
        config.subscribeAudioAll = true;
        Constants.QResult result = mRtcEngine.joinChannel(mToken, mRoomId, mUserId, config);
        Log.d(TAG, "joinChannel = " + result);
    }

    private void leaveRoom() {
        if (mIsHost) {
            mRtcMessageService.broadcastMessage(PanoMsgFactory.closeRoomMsg(), false);
        }

        mRtcEngine.stopAudio();
        mRtcEngine.leaveChannel();
        if (mDumpAudio) {
            PanoRtcMgr.getInstance().sendAudioLog();
        }
        PanoRtcMgr.getInstance().removePanoEventListener(this);
        PanoRtcMgr.getInstance().clearMusicCallback();
        PanoRtcMgr.getInstance().leaveRoom();
        PanoRtcMgr.getInstance().setInRoom(false);
        PanoUserMgr.getIns().clear();
        mIsFirstLoad = false;
        cHandler.removeCallbacksAndMessages(null);
    }

    private void sendMsg() {
        if (mMessageServiceState != Constants.MessageServiceState.Available) {
            Toast.makeText(this, "MessageService not available!", Toast.LENGTH_SHORT).show();
            return;
        }
        String msgContent = mSendMsgEdit.getText().toString();
        if (TextUtils.isEmpty(msgContent)) {
            Toast.makeText(this, R.string.room_msg_empty_warning, Toast.LENGTH_SHORT).show();
        } else {
            mRtcMessageService.broadcastMessage(
                    PanoMsgFactory.sendTextMsg(mUserId, msgContent), true);
            mSendMsgEdit.setText("");
        }
    }

    @Override
    public void onItemClick(View view, int position, PanoCmdUser user) {

        /*******************HostUser*************************/
        if (mIsHost) {
            if (user.status == PanoTypeConstant.NONE) {
                showMicInvitePop(position);
            } else if (user.status == PanoTypeConstant.DONE) {
                String[] items = new String[]{getString(R.string.room_mute_mic),
                        getString(R.string.room_force_close_mic)};
                AlertDialog.Builder listDialog = new AlertDialog.Builder(this);
                listDialog.setTitle(PanoUserMgr.getIns().getUserNameById(user.userId));
                listDialog.setItems(items, (dialog, which) -> {
                    if (which == 0) {
                        PanoUserMgr.getIns().refreshUserStatus(user.userId, PanoTypeConstant.MUTE);
                        notifyMicStatusAdapter(user.userId, PanoTypeConstant.MUTE);

                        //updateAllMic
                        PanoUserMgr.getIns().updateMicUserStatus(user.userId, PanoTypeConstant.MUTE);
                        mRtcMessageService.setProperty(ALL_MIC_KEY, PanoMsgFactory.updateAllMic());
                    } else if (which == 1) {
                        mRtcMessageService.sendMessage(user.userId, PanoMsgFactory.killUserMsg(user));
                        PanoUserMgr.getIns().refreshUserStatus(user.userId, PanoTypeConstant.NONE);
                        notifyMicStatusAdapter(user.userId, PanoTypeConstant.NONE);

                        //updateAllMic
                        PanoUserMgr.getIns().updateMicUserStatus(user.userId, PanoTypeConstant.NONE);
                        mRtcMessageService.setProperty(ALL_MIC_KEY, PanoMsgFactory.updateAllMic());
                    }
                });
                listDialog.show();
            } else if (user.status == PanoTypeConstant.MUTE) {
                String[] items = new String[]{getString(R.string.room_unmute_mic),
                        getString(R.string.room_force_close_mic)};
                AlertDialog.Builder listDialog = new AlertDialog.Builder(this);
                listDialog.setTitle(PanoUserMgr.getIns().getUserNameById(user.userId));
                listDialog.setItems(items, (dialog, which) -> {
                    if (which == 0) {
                        PanoUserMgr.getIns().refreshUserStatus(user.userId, PanoTypeConstant.DONE);
                        notifyMicStatusAdapter(user.userId, PanoTypeConstant.DONE);

                        //updateAllMic
                        PanoUserMgr.getIns().updateMicUserStatus(user.userId, PanoTypeConstant.DONE);
                        mRtcMessageService.setProperty(ALL_MIC_KEY, PanoMsgFactory.updateAllMic());
                    } else if (which == 1) {
                        PanoUserMgr.getIns().refreshUserStatus(user.userId, PanoTypeConstant.NONE);
                        mRtcMessageService.sendMessage(user.userId, PanoMsgFactory.killUserMsg(user));
                        notifyMicStatusAdapter(user.userId, PanoTypeConstant.NONE);

                        //updateAllMic
                        PanoUserMgr.getIns().updateMicUserStatus(user.userId, PanoTypeConstant.NONE);
                        mRtcMessageService.setProperty(ALL_MIC_KEY, PanoMsgFactory.updateAllMic());
                    }
                });
                listDialog.show();
            }
        /*******************HostUser*************************/

        /*******************User******************************/
        } else {
            if (mUserMicStatusAdapter.getItemStatus(mUserId) == PanoTypeConstant.NONE
                    && mUserMicStatusAdapter.getUserById(mUserId) == null
                    && !mUserMicStatusAdapter.hasUserAtPos(position)) {
                Dialog dialog = new AlertDialog.Builder(this)
                        .setTitle(R.string.room_apply)
                        .setPositiveButton(R.string.confirm, (dialog1, which) -> {
                            user.userId = mUserId;
                            user.status = PanoTypeConstant.APPLYING;
                            user.order = position;
                            mRtcMessageService.sendMessage(mHostUserId, PanoMsgFactory.sendApplyMsg(user));
                            showMicApplyWaitingPopup(user);
                            sendDelayMessage(REJECT_SELF_TIME_OUT, TIME_OUT_DELAY,user);
                        })
                        .setNegativeButton(R.string.cancel, (dialog1, which) -> {
                            mUserMicStatusAdapter.refreshUserStatus(mUserId,PanoTypeConstant.NONE);
                        })
                        .create();
                dialog.show();

            } else if (user.userId == mUserId && (user.status == PanoTypeConstant.DONE
                    || user.status == PanoTypeConstant.MUTE)) {
                Dialog dialog = new AlertDialog.Builder(this)
                        .setTitle(R.string.room_leave_mic)
                        .setPositiveButton(R.string.confirm, (dialog1, which) -> {
                            mRtcMessageService.sendMessage(mHostUserId, PanoMsgFactory.leaveMicMsg(user));
                            mRtcEngine.muteAudio();
                            mMuteCheckBox.setVisibility(View.GONE);
                            mEarMonitorIcon.setVisibility(View.GONE);
                        })
                        .setNegativeButton(R.string.cancel, null)
                        .create();
                dialog.show();
            }
            /*******************User******************************/
        }
    }

    private void showMicInvitePop(int position) {
        if (mMicInvitePopup == null) {
            mMicInvitePopup = new PopupWindow(mMicInviteView,
                    ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            mMicInvitePopup.setBackgroundDrawable(new PaintDrawable(Color.TRANSPARENT));
            mMicInvitePopup.setOutsideTouchable(true);
        }
        mMicInviteView.refreshUI();
        mMicInviteView.setMicOrder(position);
        if (!mMicInvitePopup.isShowing()) {
            mMicInvitePopup.showAtLocation(mHostPhoto, Gravity.BOTTOM, 0, 0);
        }
    }

    private void showMicApplyWaitingPopup(PanoCmdUser user) {
        if (mMicApplyWaitingPopup == null) {
            View view = LayoutInflater.from(this).inflate(R.layout.room_applying_waiting_pop, null);
            TextView cancel = view.findViewById(R.id.cancel);
            cancel.setOnClickListener(v -> {
                mMicApplyWaitingPopup.dismiss();
                mRtcMessageService.sendMessage(mHostUserId,
                        PanoMsgFactory.cancelApplyMsg(user));
                mUserMicStatusAdapter.refreshUserStatus(user.userId,PanoTypeConstant.NONE);
            });
            view.measure(0, 0);
            int viewWidth = view.getMeasuredWidth();
            mMicApplyWaitingPopup = new PopupWindow(view, viewWidth, ViewGroup.LayoutParams.WRAP_CONTENT);
        }
        mMicApplyWaitingPopup.showAtLocation(mHostPhoto, Gravity.TOP | Gravity.CENTER, 0, 0);
    }

    @Override
    public void onBackPressed() {
        onBack();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        leaveRoom();
    }

    @Override
    public void onChannelJoinConfirm(Constants.QResult result) {
        if (mIsHost) {
            mRtcEngine.startAudio();
        }

        PanoRtcMgr.getInstance().setInRoom(true);

       cHandler.post(() -> {
            if (result == Constants.QResult.OK) {
                PanoUser user = new PanoUser(mUserId, mUserName);
                user.isHost = mIsHost;
                PanoUserMgr.getIns().addUser(mUserId, user);
                mChatMsgAdapter.addMsg(getString(R.string.room_join_the_room, "'" + mUserName + "'"));
                mPeopleOnlineTv.setText(getString(R.string.room_people_online, PanoUserMgr.getIns().getUserSize()));
                mPeopleOnlineTv.setVisibility(View.VISIBLE);
            } else {
                int resId = mIsHost ? R.string.room_create_failed : R.string.room_join_failed;
                Toast.makeText(getApplicationContext(), resId, Toast.LENGTH_SHORT).show();
                finish();
            }
        });

    }

    @Override
    public void onUserJoinIndication(long userId, String userName) {

        cHandler.post(() -> {
            PanoUserMgr.getIns().addUser(userId, new PanoUser(userId, userName));
            mPeopleOnlineTv.setText(getString(R.string.room_people_online, PanoUserMgr.getIns().getUserSize()));
            mChatMsgAdapter.addMsg(getString(R.string.room_join_the_room, "'" + userName + "'"));
            if(userId == mHostUserId){
                mHostPhoto.setImageResource(AvatorUtil.getAvatorResByUserId(mHostUserId));
                mHostName.setText(PanoUserMgr.getIns().getUserNameById(mHostUserId));
            }
        });
    }

    @Override
    public void onUserLeaveIndication(long userId, Constants.UserLeaveReason reason) {

        PanoUser user = PanoUserMgr.getIns().removeUser(userId);
        PanoUserMgr.getIns().removeMicApplyUser(user.userId);
        cHandler.post(() -> {
            refreshNoticeView();
            mPeopleOnlineTv.setText(getString(R.string.room_people_online, PanoUserMgr.getIns().getUserSize()));
            mChatMsgAdapter.addMsg(getString(R.string.room_leave_the_room, "'" + user.userName + "'"));
        });
        notifyMicStatusAdapter(userId, PanoTypeConstant.NONE);
        if(mIsHost){
            //updateAllMic
            PanoUserMgr.getIns().updateMicUserStatus(userId, PanoTypeConstant.NONE);
            mRtcMessageService.setProperty(ALL_MIC_KEY, PanoMsgFactory.updateAllMic());
        }
        if (userId == mUserId && mDumpAudio) {
            PanoRtcMgr.getInstance().sendAudioLog();
        }
    }

    @Override
    public void onUserAudioMute(long userId) {
        notifyMicStatusAdapter(userId, PanoTypeConstant.MUTE);
    }

    @Override
    public void onUserAudioUnmute(long userId) {
        notifyMicStatusAdapter(userId, PanoTypeConstant.DONE);
    }

    @Override
    public void onServiceStateChanged(Constants.MessageServiceState state, Constants.QResult reason) {
        Log.i(TAG, "onServiceStateChanged state: " + state + " reason: " + reason);
        mMessageServiceState = state;
    }

    @Override
    public void onPropertyChanged(RtcPropertyAction[] props) {
        if (props == null || props.length <= 0) return;
        if (mIsHost && !mIsFirstLoad) return;
        try {
            for (RtcPropertyAction propertyAction : props) {
                if (ALL_MIC_KEY.equals(propertyAction.propName)) {
                    String dataJson = new String(propertyAction.propValue);
                    if (TextUtils.isEmpty(dataJson)) return;
                    Log.d(TAG, "onPropertyChanged json = " + dataJson);
                    PanoCmdMessage cmdMessage = mGson.fromJson(dataJson, PanoCmdMessage.class);
                    List<PanoCmdUser> userList = cmdMessage.getData();
                    cHandler.post(() -> {
                        mUserMicStatusAdapter.setDataList(userList);
                        checkMuteStatus(userList);
                    });
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        mIsFirstLoad = false;
    }

    @Override
    public void onUserMessage(long userId, byte[] data) {
        String jsonStr = new String(data);
        Log.d(TAG, "onUserMessage userId: " + userId + " data: " + jsonStr);
        int msgType;
        try {
            BaseMessage baseMessage = mGson.fromJson(jsonStr, BaseMessage.class);
            msgType = baseMessage.getCmd();
        } catch (Exception e) {
            return;
        }

        switch (msgType) {
            /***************All User*****************/
            case PanoTypeConstant.NormalChat:
                PanoNormalMessage normalMessage = mGson.fromJson(jsonStr, PanoNormalMessage.class);
                String usrName = PanoUserMgr.getIns().getUserNameById(normalMessage.getUserId());
                String content = usrName + ": " + normalMessage.getContent();
                cHandler.post(() -> mChatMsgAdapter.addMsg(content));
                break;
            case PanoTypeConstant.UploadAudioLog:
                mDumpAudio = true;
                mRtcEngine.startAudioDump(-1);
                cHandler.postDelayed(() -> mRtcEngine.stopAudioDump(), 60000);
                break;
            case PanoTypeConstant.CloseRoom:
                if (!isFinishing()) {
                   cHandler.post(() -> {
                        if (mMicApplyWaitingPopup != null && mMicApplyWaitingPopup.isShowing()) {
                            mMicApplyWaitingPopup.dismiss();
                        }
                        Dialog dialog = new AlertDialog.Builder(ChatRoomActivity.this)
                                .setTitle(R.string.room_close)
                                .setNeutralButton(R.string.confirm, (dialog1, which) -> finish())
                                .create();
                        dialog.setCanceledOnTouchOutside(false);
                        dialog.show();
                    });
                }
                break;
            /***************All User*****************/

            /***************HostUser*****************/
            case PanoTypeConstant.ApplyChat:
                PanoCmdMessage applyMessage = mGson.fromJson(jsonStr, PanoCmdMessage.class);
                List<PanoCmdUser> applyList = applyMessage.getData();
                if (applyList != null && !applyList.isEmpty()) {
                    if(PanoUserMgr.getIns().hasUserAtPos(applyList.get(0).order)){
                        PanoRtcEngine.getInstance().getMessageService()
                                .sendMessage(applyList.get(0).userId,
                                        PanoMsgFactory.declineApplyMsg(PanoTypeConstant.REASON_OCCUPIED,applyList.get(0)));
                        return ;
                    }
                    PanoUserMgr.getIns().addMicApplyUser(applyList.get(0));
                    PanoUserMgr.getIns().refreshUserStatus(applyList.get(0).userId, PanoTypeConstant.APPLYING);
                    long diff = applyMessage.getTimestamp() - System.currentTimeMillis() + TIME_OUT_DELAY;
                    sendDelayMessage(REJECT_TIME_OUT, diff,applyList.get(0));
                }
                cHandler.post(ChatRoomActivity.this::refreshNoticeView);
                break;
            case PanoTypeConstant.StopChat:
                PanoCmdMessage stopMessage = mGson.fromJson(jsonStr, PanoCmdMessage.class);
                List<PanoCmdUser> stopList = stopMessage.getData();
                if (stopList != null && !stopList.isEmpty()) {
                    PanoUserMgr.getIns().refreshUserStatus(stopList.get(0).userId, PanoTypeConstant.NONE);
                    notifyMicStatusAdapter(stopList.get(0).userId, PanoTypeConstant.NONE);

                    //updateAllMic
                    PanoUserMgr.getIns().updateMicUserStatus(stopList.get(0).userId, PanoTypeConstant.NONE);
                    mRtcMessageService.setProperty(ALL_MIC_KEY, PanoMsgFactory.updateAllMic());
                }
                break;
            case PanoTypeConstant.CancelChat:
                PanoCmdMessage cancelMessage = mGson.fromJson(jsonStr, PanoCmdMessage.class);
                List<PanoCmdUser> cancelList = cancelMessage.getData();
                if (cancelList != null && !cancelList.isEmpty()) {
                    PanoUserMgr.getIns().removeMicApplyUser(cancelList.get(0).userId);
                    PanoUserMgr.getIns().refreshUserStatus(cancelList.get(0).userId, PanoTypeConstant.NONE);
                    cHandler.post(this::refreshNoticeView);
                }
                break;
            case PanoTypeConstant.AcceptInvite:
                clearDelayMessage(mSendMessage);
                PanoCmdMessage acceptMessage = mGson.fromJson(jsonStr, PanoCmdMessage.class);
                List<PanoCmdUser> acceptList = acceptMessage.getData();
                if (acceptList != null && !acceptList.isEmpty()) {
                    if(PanoUserMgr.getIns().hasUserAtPos(acceptList.get(0).order)){
                        PanoRtcEngine.getInstance().getMessageService()
                                .sendMessage(acceptList.get(0).userId,
                                        PanoMsgFactory.declineApplyMsg(PanoTypeConstant.REASON_OCCUPIED,acceptList.get(0)));
                        return ;
                    }
                    PanoUserMgr.getIns().refreshUserStatus(acceptList.get(0).userId, PanoTypeConstant.DONE);

                    //updateAllMic
                    PanoUserMgr.getIns().addMicUser(acceptList.get(0), PanoTypeConstant.DONE);
                    mRtcMessageService.setProperty(ALL_MIC_KEY, PanoMsgFactory.updateAllMic());

                    cHandler.post(() -> {
                        mUserMicStatusAdapter.addData(acceptList.get(0).order, acceptList.get(0));
                    });
                }
                break;
            case PanoTypeConstant.RejectInvite:
                clearDelayMessage(mSendMessage);
                PanoCmdMessage rejectMessage = mGson.fromJson(jsonStr, PanoCmdMessage.class);
                List<PanoCmdUser> rejectList = rejectMessage.getData();
                if (rejectList != null && !rejectList.isEmpty()) {
                    PanoUserMgr.getIns().refreshUserStatus(rejectList.get(0).userId, PanoTypeConstant.NONE);
                    cHandler.post(()->{
                        int toastRes = R.string.room_mic_user_reject_toast;
                        if(rejectMessage.reason == PanoTypeConstant.REASON_TIMEOUT){
                            toastRes = R.string.room_mic_user_reject_timeout_toast ;
                        }
                        Toast.makeText(ChatRoomActivity.this,getString(toastRes,PanoUserMgr.getIns().getUserNameById(rejectList.get(0).userId)), Toast.LENGTH_SHORT).show();
                    });
                }
                break;
            /***************HostUser*****************/

            /***************User********************/
            case PanoTypeConstant.AcceptChat:
                clearDelayMessage(mSendMessage);
                cHandler.post(() -> {
                    if (mMicApplyWaitingPopup != null
                            && mMicApplyWaitingPopup.isShowing()) {
                        mMicApplyWaitingPopup.dismiss();
                        mRtcEngine.startAudio();
                        mMuteCheckBox.setChecked(false);
                        mMuteCheckBox.setVisibility(View.VISIBLE);
                        mEarMonitorIcon.setVisibility(View.VISIBLE);
                    }
                });
                break;
            case PanoTypeConstant.RejectChat:
                clearDelayMessage(mSendMessage);
                PanoCmdMessage rejectChatMessage = mGson.fromJson(jsonStr, PanoCmdMessage.class);
                List<PanoCmdUser> rejectChatList = rejectChatMessage.getData();
                if (rejectChatList != null && !rejectChatList.isEmpty()) {
                    mUserMicStatusAdapter.refreshUserStatus(rejectChatList.get(0).userId,PanoTypeConstant.NONE);
                    cHandler.post(() -> {
                        int toastRes = R.string.room_user_apply_reject_toast;
                        if(rejectChatMessage.reason == PanoTypeConstant.REASON_TIMEOUT){
                            toastRes = R.string.room_user_apply_reject_timeout_toast ;
                        }else if(rejectChatMessage.reason == PanoTypeConstant.REASON_OCCUPIED){
                            toastRes = R.string.room_user_apply_reject_occupied_toast;
                        }
                        Toast.makeText(ChatRoomActivity.this,
                                toastRes, Toast.LENGTH_SHORT).show();
                        if (mMicApplyWaitingPopup.isShowing()) {
                            mMicApplyWaitingPopup.dismiss();
                        }
                    });
                }
                break;
            case PanoTypeConstant.KillUser:
                cHandler.post(() -> {
                    mMuteCheckBox.setVisibility(View.GONE);
                    mEarMonitorIcon.setVisibility(View.GONE);
                    mRtcEngine.muteAudio();
                });
                break;
            case PanoTypeConstant.InviteUser:
                PanoCmdMessage inviteMessage = mGson.fromJson(jsonStr, PanoCmdMessage.class);
                List<PanoCmdUser> inviteList = inviteMessage.getData();
                if (inviteList != null && !inviteList.isEmpty()) {
                    PanoCmdUser user = inviteList.get(0);
                    user.status = PanoTypeConstant.INVITING;
                    cHandler.post(() -> {
                        mInviteDialog = new AlertDialog.Builder(ChatRoomActivity.this)
                                .setTitle(R.string.room_anchor_invite)
                                .setPositiveButton(R.string.room_user_invite_accept, (dialog1, which) -> {
                                    mRtcMessageService.sendMessage(mHostUserId,
                                            PanoMsgFactory.acceptInviteMsg(user));
                                    mMuteCheckBox.setChecked(false);
                                    mMuteCheckBox.setVisibility(View.VISIBLE);
                                    mEarMonitorIcon.setVisibility(View.VISIBLE);
                                    mRtcEngine.startAudio();
                                    Toast.makeText(this, R.string.room_anchor_invite_success, Toast.LENGTH_SHORT).show();
                                })
                                .setNegativeButton(R.string.room_user_apply_reject, (dialog1, which) -> {
                                    mRtcMessageService.sendMessage(mHostUserId,
                                            PanoMsgFactory.rejectInviteMsg(user));
                                })
                                .create();
                        mInviteDialog.show();
                    });
                    sendDelayMessage(INVITE_TIME_OUT, TIME_OUT_DELAY,user);
                }
                break;
            /***************User********************/
            default:
                break;
        }
    }


    @Override
    public void onUserAudioLevel(RtcAudioLevel level) {

        cHandler.post(() -> {
            if (mHostUserId == level.userId) {
                if (level.level > 500) {
                    mHostPhoto.startWave();
                } else {
                    mHostPhoto.stopWave();
                }
            } else {
                PanoUser user = mUserMicStatusAdapter.getUserById(level.userId);
                if (user != null) {
                    user.speaking = (user.status == PanoTypeConstant.DONE) && level.level > 500;
                    mUserMicStatusAdapter.notifyItemChanged(user.order);
                }
            }
        });
    }

    @Override
    public void onAudioMixingStateChanged(long taskId, Constants.AudioMixingState state) {
        cHandler.post(() -> {
            if (state == Constants.AudioMixingState.Started) {
                mBgmPlayIcon.setImageResource(R.drawable.icon_music_play);
            } else {
                if (PanoRtcMgr.getInstance().isPlayingBgm()) {
                    mBgmPlayIcon.setImageResource(R.drawable.icon_music_play);
                } else {
                    mBgmPlayIcon.setImageResource(R.drawable.icon_music_pause);
                }
            }
        });
    }

    @Override
    public void onBgmDestroy() {
        mBgmPlayIcon.setImageResource(R.drawable.icon_music_pause);
    }

    @Override
    public void onBgmPlay(int position) {
        mMusicSettingView.refreshPlayingBgmItem(position);
    }

    @Override
    public void onBgmPause() {
        mBgmPlayIcon.setImageResource(R.drawable.icon_music_pause);
    }

    @Override
    public void onBgmResume() {
        mBgmPlayIcon.setImageResource(R.drawable.icon_music_play);
    }

    @Override
    public void onAcceptMicApply(int micOrder, PanoCmdUser user) {
        clearDelayMessage(mSendMessage);
        refreshNoticeView();
        cHandler.post(() -> {
            mUserMicStatusAdapter.addData(micOrder, user);
        });
    }

    @Override
    public void onDeclineMicApply(PanoCmdUser user) {
        clearDelayMessage(mSendMessage);
        refreshNoticeView();
    }

    @Override
    public void onClickBack() {
        if (mMicInvitePopup.isShowing()) {
            mMicInvitePopup.dismiss();
        }
    }

    @Override
    public void onInviteUser(int micOrder, PanoUser user) {
        if (mMicInvitePopup.isShowing()) {
            mMicInvitePopup.dismiss();
        }
        user.order = micOrder;
        PanoCmdUser cmdUser = new PanoCmdUser(user);
        mRtcMessageService.sendMessage(user.userId, PanoMsgFactory.inviteMsg(cmdUser));
        PanoUserMgr.getIns().refreshUserStatus(user.userId, PanoTypeConstant.INVITING);
    }

    @Override
    public void onEarMonitorSettingCancel() {
        if (mEarMonitorPopup != null && mEarMonitorPopup.isShowing()) {
            mEarMonitorPopup.dismiss();
        }
    }

    private void checkMuteStatus(List<PanoCmdUser> users){
        for(PanoCmdUser user : users){
            if(user.userId == mUserId){
                if(user.status == PanoTypeConstant.MUTE){
                    mRtcEngine.muteAudio();
                    mMuteCheckBox.setChecked(true);
                }else if(user.status == PanoTypeConstant.DONE){
                    mRtcEngine.unmuteAudio();
                    mMuteCheckBox.setChecked(false);
                }
            }
        }
    }

    private void notifyMicStatusAdapter(long userId, int micStatus) {
        cHandler.post(() -> {
            int pos = mUserMicStatusAdapter.refreshUserStatus(userId, micStatus);
            mUserMicStatusAdapter.notifyItemChanged(pos);
        });
    }

    private void sendDelayMessage(int what , long delayTime,PanoCmdUser user){
        Message msg = new Message();
        msg.what = what;
        msg.obj = user ;
        mSendMessage = msg ;
        cHandler.sendMessageDelayed(msg,delayTime);
    }

    private void clearDelayMessage(Message message){
        if(message == null) return ;
        cHandler.removeMessages(message.what,message.obj);
    }
}
