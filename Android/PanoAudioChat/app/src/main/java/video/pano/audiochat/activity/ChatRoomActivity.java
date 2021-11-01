package video.pano.audiochat.activity;

import static video.pano.audiochat.rtc.PanoTypeConstant.ALL_MIC_KEY;
import static video.pano.audiochat.rtc.PanoTypeConstant.APPLYING;
import static video.pano.audiochat.rtc.PanoTypeConstant.AcceptChat;
import static video.pano.audiochat.rtc.PanoTypeConstant.AcceptInvite;
import static video.pano.audiochat.rtc.PanoTypeConstant.ApplyChat;
import static video.pano.audiochat.rtc.PanoTypeConstant.CancelChat;
import static video.pano.audiochat.rtc.PanoTypeConstant.CloseRoom;
import static video.pano.audiochat.rtc.PanoTypeConstant.DONE;
import static video.pano.audiochat.rtc.PanoTypeConstant.InviteUser;
import static video.pano.audiochat.rtc.PanoTypeConstant.KillUser;
import static video.pano.audiochat.rtc.PanoTypeConstant.MIC_MUTE;
import static video.pano.audiochat.rtc.PanoTypeConstant.MIC_UN_MUTE;
import static video.pano.audiochat.rtc.PanoTypeConstant.MUTE;
import static video.pano.audiochat.rtc.PanoTypeConstant.MUTE_BY_SELF;
import static video.pano.audiochat.rtc.PanoTypeConstant.NONE;
import static video.pano.audiochat.rtc.PanoTypeConstant.NormalChat;
import static video.pano.audiochat.rtc.PanoTypeConstant.REASON_OCCUPIED;
import static video.pano.audiochat.rtc.PanoTypeConstant.REASON_TIMEOUT;
import static video.pano.audiochat.rtc.PanoTypeConstant.RejectChat;
import static video.pano.audiochat.rtc.PanoTypeConstant.RejectInvite;
import static video.pano.audiochat.rtc.PanoTypeConstant.StopChat;
import static video.pano.audiochat.rtc.PanoTypeConstant.UploadAudioLog;

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

import video.pano.audiochat.PACApplication;
import video.pano.audiochat.R;
import video.pano.audiochat.adapter.ChatMsgAdapter;
import video.pano.audiochat.adapter.MicApplyAdapter;
import video.pano.audiochat.adapter.UserMicStatusAdapter;
import video.pano.audiochat.model.Song;
import video.pano.audiochat.rtc.PanoEvent;
import video.pano.audiochat.rtc.PanoRtcEngine;
import video.pano.audiochat.rtc.PanoRtcMgr;
import video.pano.audiochat.rtc.PanoUserMgr;
import video.pano.audiochat.rtc.data.BaseCmdMessage;
import video.pano.audiochat.rtc.data.PanoCmdMessage;
import video.pano.audiochat.rtc.data.PanoCmdUser;
import video.pano.audiochat.rtc.data.PanoMsgFactory;
import video.pano.audiochat.rtc.data.PanoNormalMessage;
import video.pano.audiochat.rtc.data.PanoUser;
import video.pano.audiochat.utils.AvatorUtil;
import video.pano.audiochat.utils.MiscUtils;
import video.pano.audiochat.utils.SPUtil;
import video.pano.audiochat.view.EarMonitorSettingView;
import video.pano.audiochat.view.MicApplyView;
import video.pano.audiochat.view.MicInviteView;
import video.pano.audiochat.view.MusicSettingView;
import video.pano.audiochat.view.WaitingView;
import video.pano.audiochat.view.WaveImageView;

public class ChatRoomActivity extends BaseActivity implements PanoEvent, RtcAudioMixingMgr.Callback,
        RtcAudioIndication, RtcMessageService.Callback, PanoRtcMgr.BgmCallback,
        MicApplyAdapter.DealApplyCallback, UserMicStatusAdapter.OnItemClickListener,
        MicInviteView.MicInviteCallback, EarMonitorSettingView.EarMonitorSettingCallback,
        MusicSettingView.MusicSettingCallback, WaitingView.WaitingCallback {

    private static final String TAG = "ChatRoomActivity";
    private static final String ROOM_ID = "room_id";
    private static final String USER_NAME = "user_name";
    private static final String USER_ID = "user_id";
    private static final String TOKEN = "token";
    private static final String IS_HOST = "is_host";
    private static final String HOST_USER_ID = "host_user_id";

    private static final long TIME_OUT_DELAY = 30 * 1000;

    private static final int REJECT_TIME_OUT = 100;
    private static final int REJECT_SELF_TIME_OUT = 200;
    private static final int INVITE_TIME_OUT = 300;
    private static final int CANCEL_REJECT_SELF = 400;

    public static final int LOCAL_SONG_REQUEST_CODE = 100;

    private UserMicStatusAdapter mUserMicStatusAdapter;
    private ChatMsgAdapter mChatMsgAdapter;

    private WaveImageView mHostPhoto;
    private TextView mHostName;
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
    private WaitingView mWaitingView;

    private PopupWindow mMusicSettingsPopup;
    private PopupWindow mMicApplyPopup;
    private PopupWindow mMicApplyWaitingPopup;
    private PopupWindow mMicInvitePopup;
    private PopupWindow mEarMonitorPopup;
    private Dialog mInviteDialog;


    private String mRoomId;
    private String mUserName;
    private long mUserId;
    private String mToken;
    private boolean mIsHost;
    private boolean mIsFirstLoad;

    private long mHostUserId;
    private boolean mDumpAudio = false;

    private Message mSendMessage;
    private RtcEngine mRtcEngine;
    private RtcMessageService mRtcMessageService;
    private Constants.MessageServiceState mMessageServiceState = Constants.MessageServiceState.Unavailable;
    private final Gson mGson = new Gson();
    private final ChatHandler cHandler = new ChatHandler(this);
    private boolean mAudioHighQuality;
    private TextView mRoomIdText;

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
            switch (msg.what) {
                case REJECT_TIME_OUT:
                    if ((activity.mRoomNoticeIcon == null || activity.mRoomNoticeIcon.getVisibility() == View.GONE)
                            && (activity.mMicApplyPopup == null || !activity.mMicApplyPopup.isShowing())) {
                        return;
                    }
                    PanoCmdUser user1 = (PanoCmdUser) msg.obj;
                    PanoRtcEngine.getInstance().getMessageService().sendMessage(user1.userId, PanoMsgFactory.declineApplyMsg(REASON_TIMEOUT, user1));
                    PanoUserMgr.getIns().updateAllUserStatus(user1.userId, NONE);
                    PanoUserMgr.getIns().removeMicApplyUser(user1.userId);
                    activity.onDeclineMicApply(user1);
                    break;
                case REJECT_SELF_TIME_OUT:
                    if (activity.mMicApplyWaitingPopup == null || !activity.mMicApplyWaitingPopup.isShowing()) {
                        return;
                    }
                    PanoCmdUser user2 = (PanoCmdUser) msg.obj;
                    activity.mUserMicStatusAdapter.refreshUserStatus(user2.userId, NONE);
                    Toast.makeText(activity,
                            R.string.room_user_apply_reject_timeout_toast, Toast.LENGTH_SHORT).show();
                    if (activity.mMicApplyWaitingPopup.isShowing()) {
                        activity.mMicApplyWaitingPopup.dismiss();
                    }
                    break;
                case INVITE_TIME_OUT:
                    PanoCmdUser user3 = (PanoCmdUser) msg.obj;
                    if (activity.mInviteDialog != null && activity.mInviteDialog.isShowing()) {
                        activity.mInviteDialog.dismiss();
                    }
                    PanoRtcEngine.getInstance().getMessageService().sendMessage(activity.mHostUserId,
                            PanoMsgFactory.rejectInviteMsg(REASON_TIMEOUT, user3));
                    break;
                case CANCEL_REJECT_SELF:
                    if (activity.mMicApplyWaitingPopup != null && activity.mMicApplyWaitingPopup.isShowing()) {
                        PanoCmdUser user4 = (PanoCmdUser) msg.obj;
                        activity.mUserMicStatusAdapter.refreshUserStatus(user4.userId, NONE);
                        Toast.makeText(activity,
                                R.string.room_user_apply_reject_occupied_toast, Toast.LENGTH_SHORT).show();
                        activity.mMicApplyWaitingPopup.dismiss();
                    }
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
        MiscUtils.setScreenOnFlag(getWindow());

        setContentView(R.layout.activity_chat_room);

        Intent intent = getIntent();
        mRoomId = intent.getStringExtra(ROOM_ID);
        mUserName = intent.getStringExtra(USER_NAME);
        mUserId = intent.getLongExtra(USER_ID, 0);
        mToken = intent.getStringExtra(TOKEN);
        mIsHost = intent.getBooleanExtra(IS_HOST, false);
        String hostUserId = intent.getStringExtra(HOST_USER_ID);

        mAudioHighQuality = (boolean) SPUtil.getValue(
                PACApplication.getInstance(),
                SettingActivity.KEY_AUDIO_HIGH_QUALITY,
                false);

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
        mRtcEngine.setAudioIndication(this, 50);
        mRtcEngine.getAudioMixingMgr().setCallback(this);
        mRtcMessageService = mRtcEngine.getMessageService();
        mRtcMessageService.setCallback(this);

        if (mIsHost) {
            PanoUserMgr.getIns().initMicList();
        }
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
        mRoomIdText = findViewById(R.id.room_id);

        mPeopleOnlineTv = findViewById(R.id.people_online);
        mRoomIdText.setText(mRoomId);

        if (mIsHost) {
            mMicApplyView = new MicApplyView(this);
            mMicApplyView.setDealApplyCallback(this);
            mMicInviteView = new MicInviteView(this);
            mMicInviteView.setMicInviteCallback(this);
        }else{
            mWaitingView = new WaitingView(this);
            mWaitingView.setWaitingCallback(this);
        }
    }

    private void initHeadView() {
        mHostPhoto = findViewById(R.id.host_photo);
        mHostName = findViewById(R.id.host_name);
        if (mIsHost) {
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
        mUserMicStatusAdapter = new UserMicStatusAdapter(this, mIsHost);
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
            mMusicSettingView.setMicInviteCallback(this);
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
                (buttonView, isChecked) -> {
                    if (mAudioHighQuality) {
                        Toast.makeText(this, R.string.title_high_quality_audio_tips,
                                Toast.LENGTH_SHORT).show();
                        loudspeakerCheckBox.setChecked(!isChecked);
                        return;
                    }
                    mRtcEngine.setLoudspeakerStatus(!isChecked);
                });


        mMuteCheckBox.setOnCheckedChangeListener((buttonView, isChecked) -> {

            int micStatus = mUserMicStatusAdapter.getItemStatus(mUserId);
            if (!isChecked && micStatus == MUTE) {
                Toast.makeText(this, R.string.room_anchor_forbids_speak, Toast.LENGTH_SHORT).show();
                buttonView.setChecked(true);
                return;
            }

            if (isChecked) {
                mRtcEngine.muteAudio();
                notifyMicMuteStatusAdapter(mUserId, MIC_MUTE);
                PanoUserMgr.getIns().addMuteUser(mUserId);
            } else {
                mRtcEngine.unmuteAudio();
                notifyMicMuteStatusAdapter(mUserId, MIC_UN_MUTE);
                PanoUserMgr.getIns().removeMuteUser(mUserId);
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
//            mRtcMessageService.broadcastMessage(PanoMsgFactory.closeRoomMsg(), false);
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
            if (user.status == NONE) {
                showMicInvitePop(position);
            } else if (mUserMicStatusAdapter.getUserAudioStatus(user.userId) == MIC_UN_MUTE) {
                String[] items = new String[]{getString(R.string.room_mute_mic),
                        getString(R.string.room_force_close_mic)};
                AlertDialog.Builder listDialog = new AlertDialog.Builder(this);
                listDialog.setTitle(PanoUserMgr.getIns().getUserNameById(user.userId));
                listDialog.setItems(items, (dialog, which) -> {
                    if (which == 0) {
                        //TODO updateAllMic
                        PanoUserMgr.getIns().updateAllUserStatus(user.userId, MUTE);
                        PanoUserMgr.getIns().updateMicUserStatus(user.userId, MUTE);
                        mRtcMessageService.setProperty(ALL_MIC_KEY, PanoMsgFactory.updateAllMic());

                        notifyMicMuteStatusAdapter(user.userId, MIC_MUTE);
                        PanoUserMgr.getIns().addMuteUser(user.userId);
                    } else if (which == 1) {
                        mRtcMessageService.sendMessage(user.userId, PanoMsgFactory.killUserMsg(user));
                        PanoUserMgr.getIns().updateAllUserStatus(user.userId, NONE);
                        notifyMicStatusAdapter(user.userId, NONE);
                        PanoUserMgr.getIns().updateMicUserStatus(user.userId, NONE);
                        //TODO updateAllMic
                        mRtcMessageService.setProperty(ALL_MIC_KEY, PanoMsgFactory.updateAllMic());

                    }
                });
                listDialog.show();
            } else if ( mUserMicStatusAdapter.getUserAudioStatus(user.userId) == MIC_MUTE) {
                String[] items = new String[]{getString(R.string.room_unmute_mic),
                        getString(R.string.room_force_close_mic)};
                AlertDialog.Builder listDialog = new AlertDialog.Builder(this);
                listDialog.setTitle(PanoUserMgr.getIns().getUserNameById(user.userId));
                listDialog.setItems(items, (dialog, which) -> {
                    if (which == 0) {
                        PanoUserMgr.getIns().updateAllUserStatus(user.userId, DONE);
                        PanoUserMgr.getIns().updateMicUserStatus(user.userId, DONE);
                        //TODO updateAllMic
                        mRtcMessageService.setProperty(ALL_MIC_KEY, PanoMsgFactory.updateAllMic());
                        PanoUserMgr.getIns().removeMuteUser(user.userId);
                        notifyMicMuteStatusAdapter(user.userId, MIC_UN_MUTE);
                    } else if (which == 1) {
                        PanoUserMgr.getIns().updateAllUserStatus(user.userId, NONE);
                        mRtcMessageService.sendMessage(user.userId, PanoMsgFactory.killUserMsg(user));
                        notifyMicStatusAdapter(user.userId, NONE);
                        //TODO updateAllMic
                        PanoUserMgr.getIns().updateMicUserStatus(user.userId, NONE);
                        mRtcMessageService.setProperty(ALL_MIC_KEY, PanoMsgFactory.updateAllMic());
                    }
                });
                listDialog.show();
            }
            /*******************HostUser*************************/

            /*******************User******************************/
        } else {
            if (mUserMicStatusAdapter.getItemStatus(mUserId) == NONE
                    && mUserMicStatusAdapter.getUserById(mUserId) == null
                    && !mUserMicStatusAdapter.hasUserAtPos(position)) {
                Dialog dialog = new AlertDialog.Builder(this)
                        .setTitle(R.string.room_apply)
                        .setPositiveButton(R.string.confirm, (dialog1, which) -> {
                            if(mUserMicStatusAdapter.getUserById(mUserId) == null){
                                user.userId = mUserId;
                                user.status = APPLYING;
                                user.order = position;
                                mRtcMessageService.sendMessage(mHostUserId, PanoMsgFactory.sendApplyMsg(user));
                                showMicApplyWaitingPopup(user);
                                sendDelayMessage(REJECT_SELF_TIME_OUT, TIME_OUT_DELAY, user);
                            }
                        })
                        .setNegativeButton(R.string.cancel, (dialog1, which) -> {
                            if(mUserMicStatusAdapter.getUserById(mUserId) == null){
                                mUserMicStatusAdapter.refreshUserStatus(mUserId, NONE);
                            }
                        })
                        .create();
                dialog.show();

            } else if (user.userId == mUserId && (user.status == DONE
                    || user.status == MUTE || user.status == MUTE_BY_SELF)) {
                Dialog dialog = new AlertDialog.Builder(this)
                        .setTitle(R.string.room_leave_mic)
                        .setPositiveButton(R.string.confirm, (dialog1, which) -> {
                            mRtcMessageService.sendMessage(mHostUserId, PanoMsgFactory.leaveMicMsg(user));
                            PanoUserMgr.getIns().removeMuteUser(mUserId);
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
            mMicApplyWaitingPopup = new PopupWindow(mWaitingView, ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT);
            mMicApplyWaitingPopup.setBackgroundDrawable(new PaintDrawable(Color.TRANSPARENT));
            mMicApplyWaitingPopup.setOutsideTouchable(false);
        }
        mWaitingView.setCmdUser(user);
        if (!mMicApplyWaitingPopup.isShowing()) {
            mMicApplyWaitingPopup.showAtLocation(mHostPhoto, Gravity.TOP | Gravity.CENTER, 0, 0);
        }
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
    public void onChannelLeaveIndication(Constants.QResult result) {
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
    }

    @Override
    public void onUserJoinIndication(long userId, String userName) {

        cHandler.post(() -> {
            PanoUserMgr.getIns().addUser(userId, new PanoUser(userId, userName));
            mPeopleOnlineTv.setText(getString(R.string.room_people_online, PanoUserMgr.getIns().getUserSize()));
            mChatMsgAdapter.addMsg(getString(R.string.room_join_the_room, "'" + userName + "'"));
            if (userId == mHostUserId) {
                mHostPhoto.setImageResource(AvatorUtil.getAvatorResByUserId(mHostUserId));
                mHostName.setText(PanoUserMgr.getIns().getUserNameById(mHostUserId));
            }
            if(mIsHost && mMicInviteView != null) mMicInviteView.refreshUI();
        });
    }

    @Override
    public void onUserLeaveIndication(long userId, Constants.UserLeaveReason reason) {
        cHandler.post(() -> {
            PanoUser user = PanoUserMgr.getIns().removeUser(userId);
            PanoUserMgr.getIns().removeMicApplyUser(user.userId);
            refreshNoticeView();
            mPeopleOnlineTv.setText(getString(R.string.room_people_online, PanoUserMgr.getIns().getUserSize()));
            mChatMsgAdapter.addMsg(getString(R.string.room_leave_the_room, "'" + user.userName + "'"));
            notifyMicStatusAdapter(userId, NONE);
            if (mIsHost) {
                //TODO updateAllMic
                PanoUserMgr.getIns().updateMicUserStatus(userId, NONE);
                mRtcMessageService.setProperty(ALL_MIC_KEY, PanoMsgFactory.updateAllMic());
                if(mMicInviteView != null) mMicInviteView.refreshUI();
            }
            if (userId == mUserId && mDumpAudio) {
                PanoRtcMgr.getInstance().sendAudioLog();
            }
        });
    }

    @Override
    public void onUserAudioMute(long userId) {
        notifyMicMuteStatusAdapter(userId, MIC_MUTE);
        PanoUserMgr.getIns().addMuteUser(userId);
        if(mIsHost && PanoUserMgr.getIns().getMicUserStatus(userId) == DONE){
            PanoUserMgr.getIns().updateMicUserStatus(userId,MUTE_BY_SELF);
        }
    }

    @Override
    public void onUserAudioUnmute(long userId) {
        notifyMicMuteStatusAdapter(userId, MIC_UN_MUTE);
        PanoUserMgr.getIns().removeMuteUser(userId);
        if(mIsHost){
            PanoUserMgr.getIns().updateMicUserStatus(userId,DONE);
        }
    }

    @Override
    public void onChannelFailover(Constants.FailoverState failoverState) {
        View loadingView = findViewById(R.id.loading_layout);
        if (failoverState.equals(Constants.FailoverState.Reconnecting)) {
            loadingView.setVisibility(View.VISIBLE);
        } else {
            loadingView.setVisibility(View.GONE);
        }
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
                        checkUserStatus(userList);
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
            BaseCmdMessage baseCmdMessage = mGson.fromJson(jsonStr, BaseCmdMessage.class);
            msgType = baseCmdMessage.getCmd();
        } catch (Exception e) {
            return;
        }

        switch (msgType) {
            /***************All User*****************/
            case NormalChat:
                PanoNormalMessage normalMessage = mGson.fromJson(jsonStr, PanoNormalMessage.class);
                String usrName = PanoUserMgr.getIns().getUserNameById(normalMessage.getUserId());
                String content = usrName + ": " + normalMessage.getContent();
                cHandler.post(() -> mChatMsgAdapter.addMsg(content));
                break;
            case UploadAudioLog:
                mDumpAudio = true;
                mRtcEngine.startAudioDump(-1);
                cHandler.postDelayed(() -> mRtcEngine.stopAudioDump(), 60000);
                break;
            case CloseRoom:
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
            case ApplyChat:
                PanoCmdMessage applyMessage = mGson.fromJson(jsonStr, PanoCmdMessage.class);
                List<PanoCmdUser> applyList = applyMessage.getData();
                if (applyList != null && !applyList.isEmpty()) {
                    PanoCmdUser applyUser = applyList.get(0);
                    if (PanoUserMgr.getIns().hasUserAtPos(applyUser.order)
                            || PanoUserMgr.getIns().getUserStatus(applyUser.userId) == APPLYING
                            || PanoUserMgr.getIns().getUserStatus(applyUser.userId) == DONE) {
                        PanoRtcEngine.getInstance().getMessageService()
                                .sendMessage(applyUser.userId,
                                        PanoMsgFactory.declineApplyMsg(REASON_OCCUPIED, applyList.get(0)));
                        return;
                    }
                    PanoUserMgr.getIns().addMicApplyUser(applyUser);
                    PanoUserMgr.getIns().updateAllUserStatus(applyUser.userId, APPLYING);
                    long diff = applyMessage.getTimestamp() - System.currentTimeMillis() + TIME_OUT_DELAY;
                    sendDelayMessage(REJECT_TIME_OUT, diff, applyUser);
                }
                cHandler.post(ChatRoomActivity.this::refreshNoticeView);
                break;
            case StopChat:
                PanoCmdMessage stopMessage = mGson.fromJson(jsonStr, PanoCmdMessage.class);
                List<PanoCmdUser> stopList = stopMessage.getData();
                if (stopList != null && !stopList.isEmpty()) {
                    PanoUserMgr.getIns().updateAllUserStatus(stopList.get(0).userId, NONE);
                    //TODO updateAllMic
                    notifyMicStatusAdapter(stopList.get(0).userId, NONE);
                    PanoUserMgr.getIns().updateMicUserStatus(stopList.get(0).userId, NONE);
                    mRtcMessageService.setProperty(ALL_MIC_KEY, PanoMsgFactory.updateAllMic());
                }
                break;
            case CancelChat:
                PanoCmdMessage cancelMessage = mGson.fromJson(jsonStr, PanoCmdMessage.class);
                List<PanoCmdUser> cancelList = cancelMessage.getData();
                if (cancelList != null && !cancelList.isEmpty()) {
                    PanoUserMgr.getIns().removeMicApplyUser(cancelList.get(0).userId);
                    PanoUserMgr.getIns().updateAllUserStatus(cancelList.get(0).userId, NONE);
                    cHandler.post(this::refreshNoticeView);
                }
                break;
            case AcceptInvite:
                clearDelayMessage(mSendMessage);
                PanoCmdMessage acceptMessage = mGson.fromJson(jsonStr, PanoCmdMessage.class);
                List<PanoCmdUser> acceptList = acceptMessage.getData();
                if (acceptList != null && !acceptList.isEmpty()) {
                    PanoCmdUser acceptUser = acceptList.get(0);
                    if (PanoUserMgr.getIns().hasUserAtPos(acceptUser.order)
                            || PanoUserMgr.getIns().getUserStatus(acceptUser.userId) == DONE ) {
                        PanoRtcEngine.getInstance().getMessageService()
                                .sendMessage(acceptUser.userId,
                                        PanoMsgFactory.declineApplyMsg(REASON_OCCUPIED, acceptUser));
                        return;
                    }
                    PanoUserMgr.getIns().updateAllUserStatus(acceptUser.userId, DONE);
                    PanoUserMgr.getIns().addMicUser(acceptUser, DONE);
                    //TODO updateAllMic
                    mRtcMessageService.setProperty(ALL_MIC_KEY, PanoMsgFactory.updateAllMic());
                    cHandler.post(() -> {
                        mUserMicStatusAdapter.addData(acceptUser.order, acceptUser);
                    });
                }
                break;
            case RejectInvite:
                clearDelayMessage(mSendMessage);
                PanoCmdMessage rejectMessage = mGson.fromJson(jsonStr, PanoCmdMessage.class);
                List<PanoCmdUser> rejectList = rejectMessage.getData();
                if (rejectList != null && !rejectList.isEmpty()) {
                    PanoUserMgr.getIns().updateAllUserStatus(rejectList.get(0).userId, NONE);
                    cHandler.post(() -> {
                        int toastRes = R.string.room_mic_user_reject_toast;
                        if (rejectMessage.reason == REASON_TIMEOUT) {
                            toastRes = R.string.room_mic_user_reject_timeout_toast;
                        }
                        Toast.makeText(ChatRoomActivity.this, getString(toastRes, PanoUserMgr.getIns().getUserNameById(rejectList.get(0).userId)), Toast.LENGTH_SHORT).show();
                    });
                }
                break;
            /***************HostUser*****************/

            /***************User********************/
            case AcceptChat:
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
            case RejectChat:
                clearDelayMessage(mSendMessage);
                PanoCmdMessage rejectChatMessage = mGson.fromJson(jsonStr, PanoCmdMessage.class);
                List<PanoCmdUser> rejectChatList = rejectChatMessage.getData();
                if (rejectChatList != null && !rejectChatList.isEmpty()) {
                    mUserMicStatusAdapter.refreshUserStatus(rejectChatList.get(0).userId, NONE);
                    cHandler.post(() -> {
                        int toastRes = R.string.room_user_apply_reject_toast;
                        if (rejectChatMessage.reason == REASON_TIMEOUT) {
                            toastRes = R.string.room_user_apply_reject_timeout_toast;
                        } else if (rejectChatMessage.reason == REASON_OCCUPIED) {
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
            case KillUser:
                cHandler.post(() -> {
                    mMuteCheckBox.setVisibility(View.GONE);
                    mEarMonitorIcon.setVisibility(View.GONE);
                    PanoUserMgr.getIns().removeMuteUser(mUserId);
                    mRtcEngine.muteAudio();
                    Toast.makeText(ChatRoomActivity.this,
                            R.string.room_user_killed_toast, Toast.LENGTH_SHORT).show();
                });
                break;
            case InviteUser:
                PanoCmdMessage inviteMessage = mGson.fromJson(jsonStr, PanoCmdMessage.class);
                List<PanoCmdUser> inviteList = inviteMessage.getData();
                if (inviteList != null && !inviteList.isEmpty()) {
                    PanoCmdUser user = inviteList.get(0);
                    sendDelayMessage(CANCEL_REJECT_SELF, 0, user);

                    user.status = APPLYING;
                    cHandler.post(() -> {
                        mInviteDialog = new AlertDialog.Builder(ChatRoomActivity.this)
                                .setTitle(R.string.room_anchor_invite)
                                .setPositiveButton(R.string.room_user_invite_accept, (dialog1, which) -> {
                                    clearDelayMessage(mSendMessage);
                                    mRtcMessageService.sendMessage(mHostUserId,
                                            PanoMsgFactory.acceptInviteMsg(user));
                                    mMuteCheckBox.setChecked(false);
                                    mMuteCheckBox.setVisibility(View.VISIBLE);
                                    mEarMonitorIcon.setVisibility(View.VISIBLE);
                                    mRtcEngine.startAudio();
                                    Toast.makeText(this, R.string.room_anchor_invite_success, Toast.LENGTH_SHORT).show();
                                })
                                .setNegativeButton(R.string.room_user_apply_reject, (dialog1, which) -> {
                                    clearDelayMessage(mSendMessage);
                                    mRtcMessageService.sendMessage(mHostUserId,
                                            PanoMsgFactory.rejectInviteMsg(user));
                                })
                                .create();
                        mInviteDialog.show();
                    });
                    sendDelayMessage(INVITE_TIME_OUT, TIME_OUT_DELAY, user);
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
                    user.speaking = (user.status == DONE) && level.level > 500;
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
        PanoUserMgr.getIns().updateAllUserStatus(user.userId, APPLYING);

        PanoUserMgr.getIns().removeMicApplyUser(user.userId);
        refreshNoticeView();
    }

    @Override
    public void onEarMonitorSettingCancel() {
        if (mEarMonitorPopup != null && mEarMonitorPopup.isShowing()) {
            mEarMonitorPopup.dismiss();
        }
    }

    @Override
    public void onClickLocalSong() {
        Intent intent = new Intent(this, LocalSongActivity.class);
        startActivityIfNeeded(intent, LOCAL_SONG_REQUEST_CODE);
    }

    @Override
    public void onClickCancel(PanoCmdUser user) {
        if (mMicApplyWaitingPopup.isShowing()) {
            mMicApplyWaitingPopup.dismiss();
        }
        mRtcMessageService.sendMessage(mHostUserId,
                PanoMsgFactory.cancelApplyMsg(user));
        mUserMicStatusAdapter.refreshUserStatus(user.userId, NONE);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == LOCAL_SONG_REQUEST_CODE && data != null && data.hasExtra(LocalSongActivity.EXTRA_SONG_DATA)) {
            Song song = (Song) data.getSerializableExtra(LocalSongActivity.EXTRA_SONG_DATA);
            mMusicSettingView.setLocalSong(song);
        }
    }

    private void checkUserStatus(List<PanoCmdUser> users) {
        boolean isMicUser = false;
        for (PanoCmdUser user : users) {
            if (user.userId == mUserId) {
                if (user.status == MUTE || user.status == MUTE_BY_SELF) {
                    mRtcEngine.muteAudio();
                    mMuteCheckBox.setChecked(true);
                }else if(user.status == DONE){
                    mRtcEngine.unmuteAudio();
                    mMuteCheckBox.setChecked(false);
                }
                isMicUser = true;
            }
        }
        if (!isMicUser && !mIsHost) {
            mRtcEngine.muteAudio();
            mMuteCheckBox.setVisibility(View.GONE);
            mEarMonitorIcon.setVisibility(View.GONE);
        }
    }

    private void notifyMicMuteStatusAdapter(long userId, int muteStatus) {
        cHandler.post(() -> {
           mUserMicStatusAdapter.refreshUserAudioStatus(userId, muteStatus);
        });
    }

    private void notifyMicStatusAdapter(long userId, int micStatus) {
        cHandler.post(() -> {
           mUserMicStatusAdapter.refreshUserStatus(userId, micStatus);
        });
    }

    private void sendDelayMessage(int what, long delayTime, PanoCmdUser user) {
        Message msg = new Message();
        msg.what = what;
        msg.obj = user;
        mSendMessage = msg;
        cHandler.sendMessageDelayed(msg, delayTime);
    }

    private void clearDelayMessage(Message message) {
        if (message == null) return;
        cHandler.removeMessages(message.what, message.obj);
    }
}
