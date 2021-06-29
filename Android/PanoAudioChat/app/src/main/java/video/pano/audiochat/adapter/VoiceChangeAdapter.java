package video.pano.audiochat.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.pano.rtc.api.Constants;

import video.pano.audiochat.R;
import video.pano.audiochat.rtc.PanoRtcEngine;
import video.pano.audiochat.rtc.PanoRtcMgr;
import video.pano.audiochat.utils.SPUtil;

public class VoiceChangeAdapter extends BaseAdapter {

    public static final String KEY_LAST_SELECTED_VOICE = "last_voice";
    private Context mContext;
    private LayoutInflater mInflater;
    private String[] mVoiceDesList;
    private ImageView mLastCheckedImg;
    private int lastCheckedPos;

    public VoiceChangeAdapter(Context context) {
        mContext = context;
        mInflater = LayoutInflater.from(context);
        mVoiceDesList = context.getResources().getStringArray(R.array.voice_list);
        lastCheckedPos = (int) SPUtil.getValue(context, KEY_LAST_SELECTED_VOICE, 0);
    }

    @Override
    public int getCount() {
        return mVoiceDesList.length;
    }

    @Override
    public String getItem(int position) {
        return mVoiceDesList[position];
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        final ViewHolder holder;
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.voice_change_item, null);
            holder = new ViewHolder();
            holder.textView = convertView.findViewById(R.id.des);
            holder.checkedImg = convertView.findViewById(R.id.check_img);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }
        holder.textView.setText(getItem(position));

        if (mLastCheckedImg == null && lastCheckedPos == position) {
            holder.checkedImg.setVisibility(View.VISIBLE);
            mLastCheckedImg = holder.checkedImg;
        }

        convertView.setOnClickListener(v -> {
            lastCheckedPos = position;
            mLastCheckedImg.setVisibility(View.GONE);
            holder.checkedImg.setVisibility(View.VISIBLE);
            mLastCheckedImg = holder.checkedImg;

            SPUtil.setValue(mContext, VoiceChangeAdapter.KEY_LAST_SELECTED_VOICE, position);
            PanoRtcEngine.getInstance().setOption(Constants.PanoOptionType.AudioVoiceChangerMode,
                    PanoRtcMgr.getInstance().getAudioVoiceChangerOption(position));
        });
        return convertView;
    }

    private static class ViewHolder {
        private TextView textView;
        private ImageView checkedImg;
    }
}
