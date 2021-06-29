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
import video.pano.audiochat.rtc.PanoUserMgr;
import video.pano.audiochat.rtc.data.PanoCmdUser;
import video.pano.audiochat.rtc.data.PanoUser;

public class MicInviteAdapter extends BaseAdapter {

    private List<PanoUser> mUserList = new ArrayList<>();
    private LayoutInflater mInflater;
    private MicInviteChooseCallback mMicInviteChooseCallback;

    public MicInviteAdapter(Context context) {
        mInflater = LayoutInflater.from(context);
    }

    public void setData(List<PanoUser> userList) {
        mUserList.clear();
        mUserList.addAll(userList);
    }

    @Override
    public int getCount() {
        return mUserList.size();
    }

    @Override
    public PanoUser getItem(int position) {
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
            convertView = mInflater.inflate(R.layout.room_mic_invite_item, null);
            holder = new ViewHolder();
            holder.userName = convertView.findViewById(R.id.host_name);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }
        PanoUser user = getItem(position);
        holder.userName.setText(PanoUserMgr.getIns().getUserNameById(user.userId));

        convertView.setOnClickListener(v -> {
            if (mMicInviteChooseCallback != null) {
                mMicInviteChooseCallback.onInviteUser(user);
            }
        });

        return convertView;
    }

    private static class ViewHolder {
        private TextView userName;
    }

    public void setMicInviteChooseCallback(MicInviteChooseCallback callback) {
        mMicInviteChooseCallback = callback;
    }

    public interface MicInviteChooseCallback {
        void onInviteUser(PanoUser user);
    }
}
