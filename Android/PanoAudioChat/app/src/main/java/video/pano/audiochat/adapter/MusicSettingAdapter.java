package video.pano.audiochat.adapter;

import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import video.pano.audiochat.R;
import video.pano.audiochat.rtc.PanoRtcMgr;

public class MusicSettingAdapter extends BaseAdapter {

    private Context mContext;
    private String[] mMusicNames;
    private boolean mIsBgm;
    private LayoutInflater mInflater;
    private int mLastSelectedPos = -1;
    private TextView mLastSelectedView;
    private int mVolume = 100;

    public MusicSettingAdapter(Context context, boolean isBgm) {
        mContext = context;
        mIsBgm = isBgm;
        if (isBgm) {
            mMusicNames = context.getResources().getStringArray(R.array.bgm_names);
        } else {
            mMusicNames = context.getResources().getStringArray(R.array.sound_types);
        }

        mInflater = LayoutInflater.from(context);
    }

    public void setVolume(int volume) {
        mVolume = volume;
    }

    @Override
    public int getCount() {
        return mMusicNames.length;
    }

    @Override
    public String getItem(int position) {
        return mMusicNames[position];
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        final ViewHolder holder;
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.bgm_item, null);
            holder = new ViewHolder();
            holder.textView = (TextView) convertView;
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        if (mIsBgm) {
            if (mLastSelectedPos == position) {
                holder.textView.setBackgroundResource(R.drawable.bgm_item_bg_blue);
                holder.textView.setTextColor(Color.WHITE);
            } else {
                holder.textView.setBackgroundResource(R.drawable.bgm_item_bg_white);
                holder.textView.setTextColor(mContext.getResources().getColor(R.color.color_333));
            }
        }

        holder.textView.setText(getItem(position));
        holder.textView.setOnClickListener(v -> {

            if (mIsBgm) {
                if (mLastSelectedView != null) {
                    mLastSelectedView.setBackgroundResource(R.drawable.bgm_item_bg_white);
                    mLastSelectedView.setTextColor(mContext.getResources().getColor(R.color.color_333));
                }

                if (mLastSelectedPos != position) {
                    holder.textView.setBackgroundResource(R.drawable.bgm_item_bg_blue);
                    holder.textView.setTextColor(Color.WHITE);
                    PanoRtcMgr.getInstance().playBgm(position, mVolume);
                    mLastSelectedPos = position;
                    mLastSelectedView = holder.textView;
                } else {
                    holder.textView.setBackgroundResource(R.drawable.bgm_item_bg_white);
                    holder.textView.setTextColor(mContext.getResources().getColor(R.color.color_333));
                    PanoRtcMgr.getInstance().destroyBgmMusic();
                    mLastSelectedPos = -1;
                    mLastSelectedView = null;
                }

            } else {
                PanoRtcMgr.getInstance().playSound(position, mVolume);
            }

        });
        return convertView;
    }

    public void setSelectedItem(TextView selectedView, int position) {
        if (mLastSelectedPos != position) {

            if (mLastSelectedView != null) {
                mLastSelectedView.setBackgroundResource(R.drawable.bgm_item_bg_white);
                mLastSelectedView.setTextColor(mContext.getResources().getColor(R.color.color_333));
            }
            if (selectedView != null) {
                selectedView.setBackgroundResource(R.drawable.bgm_item_bg_blue);
                selectedView.setTextColor(Color.WHITE);
            }

            mLastSelectedPos = position;
            mLastSelectedView = selectedView;
        }
    }

    private static class ViewHolder {
        private TextView textView;
    }
}
