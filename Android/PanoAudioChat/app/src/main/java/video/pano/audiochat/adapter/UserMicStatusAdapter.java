package video.pano.audiochat.adapter;

import android.content.Context;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;

import video.pano.audiochat.PACApplication;
import video.pano.audiochat.R;
import video.pano.audiochat.rtc.PanoTypeConstant;
import video.pano.audiochat.rtc.PanoUserMgr;
import video.pano.audiochat.rtc.data.PanoCmdUser;
import video.pano.audiochat.rtc.data.PanoUser;
import video.pano.audiochat.utils.AvatorUtil;
import video.pano.audiochat.view.WaveImageView;

import static video.pano.audiochat.rtc.PanoTypeConstant.DEFAULT_MIC_SIZE;

public class UserMicStatusAdapter extends RecyclerView.Adapter<UserMicStatusAdapter.Holder> {

    private Context mContext;
    private List<PanoUser> mDataList;
    private int mAvatorSize;
    private int mMuteIconSize;
    private boolean mIsHost;

    public UserMicStatusAdapter(Context context, boolean isHost) {
        mContext = context;
        DisplayMetrics dm = context.getResources().getDisplayMetrics();
        mAvatorSize = dm.widthPixels / 6;
        mMuteIconSize = mAvatorSize / 4;
        mIsHost = isHost;
    }

    @NonNull
    @Override
    public Holder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = View.inflate(mContext, R.layout.room_mic_status_item, null);
        return new Holder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull UserMicStatusAdapter.Holder holder, int position) {
        holder.micIcon.setOnClickListener(v -> {
            if (mOnItemClickListener != null) {
                PanoCmdUser cmdUser = new PanoCmdUser(mDataList.get(position));
                mOnItemClickListener.onItemClick(v, position, cmdUser);
            }
        });
        PanoUser user = mDataList.get(position);
        holder.micStatus.setText(getMicStatusStr(user));
        holder.micIcon.setImageResource(getHeadImageRes(user));
        if (user.status == PanoTypeConstant.MUTE) {
            holder.muteIcon.setVisibility(View.VISIBLE);
        } else {
            holder.muteIcon.setVisibility(View.GONE);
        }

        ViewGroup.LayoutParams avatorParams = holder.micIcon.getLayoutParams();
        avatorParams.width = mAvatorSize;
        avatorParams.height = mAvatorSize;
        holder.micIcon.setLayoutParams(avatorParams);

        ViewGroup.LayoutParams muteIconParams = holder.muteIcon.getLayoutParams();
        muteIconParams.width = mMuteIconSize;
        muteIconParams.height = mMuteIconSize;
        holder.muteIcon.setLayoutParams(muteIconParams);

        if (user.speaking) {
            holder.micIcon.startWave();
        } else {
            holder.micIcon.stopWave();
        }
    }

    private String getMicStatusStr(PanoUser user) {
        if (user.status == PanoTypeConstant.DONE || user.status == PanoTypeConstant.MUTE) {
            return PanoUserMgr.getIns().getUserNameById(user.userId);
        }
        return mIsHost ? PACApplication.getInstance().getString(R.string.room_invite)
                : PACApplication.getInstance().getString(R.string.room_apply);
    }

    private int getHeadImageRes(PanoUser user) {
        return (user.status == PanoTypeConstant.NONE || user.status == PanoTypeConstant.APPLYING || user.userId <= 0) ?
                R.drawable.user_mic_status_default : AvatorUtil.getAvatorResByUserId(user.userId);
    }

    @Override
    public int getItemCount() {
        return mDataList != null ? mDataList.size() : 0;
    }

    public void initData() {
        mDataList = new ArrayList<>();
        for (int i = 0; i < DEFAULT_MIC_SIZE; i++) {
            mDataList.add(new PanoUser(i));
        }
    }

    public PanoUser getUserById(long userId) {
        for (PanoUser user : mDataList) {
            if (user.userId == userId) {
                return user;
            }
        }
        return null;
    }

    public void setDataList(List<PanoCmdUser> userList) {
        mDataList.clear();
        for (PanoCmdUser cmdUser : userList) {
            mDataList.add(new PanoUser(cmdUser));
        }
        notifyDataSetChanged();
    }

    public void addData(int micOrder, PanoCmdUser user) {
        if (user == null) return;
        mDataList.set(micOrder, new PanoUser(user));
        refreshUserStatus(user.userId, PanoTypeConstant.DONE);
        notifyItemChanged(micOrder);
    }

    public int refreshUserStatus(long userId, int micStatus) {
        PanoUser user = getUserById(userId);
        if (user == null) return -1;
        int order = user.order;
        switch (micStatus) {
            case PanoTypeConstant.NONE:
                user.status = micStatus;
                user.recycle();
                break;
            default:
                user.status = micStatus;
                break;
        }
        return order;
    }

    public int getItemStatus(long userId) {
        PanoUser user = getUserById(userId);
        if (user == null) return PanoTypeConstant.NONE;
        return user.status;
    }

    public boolean hasUserAtPos(int order) {
        PanoUser user = mDataList.get(order);
        return user != null && user.userId > 0;
    }

    public static class Holder extends RecyclerView.ViewHolder {

        public TextView micStatus;
        public WaveImageView micIcon;
        public ImageView muteIcon;

        public Holder(@NonNull View itemView) {
            super(itemView);

            micStatus = itemView.findViewById(R.id.host_name);
            micIcon = itemView.findViewById(R.id.mic_icon);
            muteIcon = itemView.findViewById(R.id.mute_icon);
        }
    }

    private OnItemClickListener mOnItemClickListener;

    public void setOnItemClickListener(OnItemClickListener onItemClickListener) {
        mOnItemClickListener = onItemClickListener;
    }

    public interface OnItemClickListener {
        void onItemClick(View view, int position, PanoCmdUser user);
    }
}
