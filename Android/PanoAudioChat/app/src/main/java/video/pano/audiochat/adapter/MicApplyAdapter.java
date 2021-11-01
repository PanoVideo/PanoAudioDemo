package video.pano.audiochat.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import video.pano.audiochat.R;
import video.pano.audiochat.rtc.PanoRtcEngine;
import video.pano.audiochat.rtc.PanoTypeConstant;
import video.pano.audiochat.rtc.PanoUserMgr;
import video.pano.audiochat.rtc.data.PanoCmdUser;
import video.pano.audiochat.rtc.data.PanoMsgFactory;

import static video.pano.audiochat.rtc.PanoTypeConstant.ALL_MIC_KEY;

public class MicApplyAdapter extends BaseAdapter {

    private Context mContext;
    private LayoutInflater mInflater;
    private List<PanoCmdUser> mUserList = new ArrayList<>();

    public MicApplyAdapter(Context context) {
        mContext = context;
        mInflater = LayoutInflater.from(context);
    }

    public void setDataList(List<PanoCmdUser> userList) {
        mUserList.clear();
        mUserList.addAll(userList);
    }

    @Override
    public int getCount() {
        return mUserList.size();
    }

    @Override
    public PanoCmdUser getItem(int position) {
        return mUserList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.room_mic_apply_item, null);
            holder = new ViewHolder();
            holder.userInfo = convertView.findViewById(R.id.user_info);
            holder.allow = convertView.findViewById(R.id.allow);
            holder.decline = convertView.findViewById(R.id.decline);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        PanoCmdUser user = getItem(position);

        holder.userInfo.setText(mContext.getString(R.string.room_user_applying,
                "'" + PanoUserMgr.getIns().getUserNameById(user.userId)) + "'");

        holder.allow.setOnClickListener(v -> {
            PanoUserMgr.getIns().updateAllUserStatus(user.userId, PanoTypeConstant.DONE);
            PanoUserMgr.getIns().removeMicApplyUser(user.userId);
            PanoRtcEngine.getInstance().getMessageService().sendMessage(user.userId,
                    PanoMsgFactory.acceptApplyMsg(user));

            //TODO updateAllMic
            PanoUserMgr.getIns().addMicUser(user,PanoTypeConstant.DONE);
            PanoRtcEngine.getInstance().getMessageService().setProperty(ALL_MIC_KEY,PanoMsgFactory.updateAllMic());

            if (mDealApplyCallback != null) mDealApplyCallback.onAcceptMicApply(user.order, user);

            if(PanoUserMgr.getIns().getMicApplyCount() > 0){
                List<PanoCmdUser> temp = new ArrayList<>(PanoUserMgr.getIns().getMicApplyList());
                PanoUserMgr.getIns().getMicApplyList().clear();
                for(PanoCmdUser otherUser : temp){
                    if(user.order == otherUser.order){
                        if (mDealApplyCallback != null) mDealApplyCallback.onDeclineMicApply(otherUser);
                        PanoRtcEngine.getInstance().getMessageService().sendMessage(otherUser.userId,PanoMsgFactory.declineApplyMsg(otherUser));
                        PanoUserMgr.getIns().updateAllUserStatus(otherUser.userId, PanoTypeConstant.NONE);
                    }
                }
            }
        });
        holder.decline.setOnClickListener(v -> {
            PanoUserMgr.getIns().removeMicApplyUser(user.userId);
            if (mDealApplyCallback != null) mDealApplyCallback.onDeclineMicApply(user);
            PanoUserMgr.getIns().updateAllUserStatus(user.userId, PanoTypeConstant.NONE);
            PanoRtcEngine.getInstance().getMessageService().sendMessage(user.userId,PanoMsgFactory.declineApplyMsg(user));
        });

        return convertView;
    }

    private static class ViewHolder {
        private TextView userInfo;
        private TextView allow;
        private TextView decline;
    }

    private DealApplyCallback mDealApplyCallback;
    public void setDealApplyCallback(DealApplyCallback callback) {
        mDealApplyCallback = callback;
    }

    public interface DealApplyCallback {
        void onAcceptMicApply(int micOrder, PanoCmdUser user);
        void onDeclineMicApply(PanoCmdUser user);
    }
}
