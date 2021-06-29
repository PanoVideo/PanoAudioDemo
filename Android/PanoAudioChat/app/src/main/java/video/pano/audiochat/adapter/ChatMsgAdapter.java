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

public class ChatMsgAdapter extends BaseAdapter {

    private List<String> mMsgList = new ArrayList<>();
    private LayoutInflater mInflater;

    public ChatMsgAdapter(Context context) {
        mInflater = LayoutInflater.from(context);
    }

    public void addMsg(String msg) {
        mMsgList.add(msg);
        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return mMsgList.size();
    }

    @Override
    public String getItem(int position) {
        if (position < 0 || position > mMsgList.size()) {
            return "";
        }
        return mMsgList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.room_chat_msg_item, null);
            holder = new ViewHolder();
            holder.msgView =  convertView.findViewById(R.id.chat_msg_tv);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }
        holder.msgView.setText(mMsgList.get(position));
        return convertView;

    }

    private static class ViewHolder {
        private TextView msgView;
    }

}
