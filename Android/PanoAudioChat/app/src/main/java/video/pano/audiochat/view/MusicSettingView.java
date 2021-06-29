package video.pano.audiochat.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.GridView;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatSeekBar;
import androidx.constraintlayout.widget.ConstraintLayout;

import video.pano.audiochat.R;
import video.pano.audiochat.adapter.MusicSettingAdapter;
import video.pano.audiochat.rtc.PanoRtcMgr;

public class MusicSettingView extends ConstraintLayout {

    private GridView mBgmGrid;
    private MusicSettingAdapter mBgmAdapter;
    private MusicSettingAdapter mSoundAdapter;

    public MusicSettingView(@NonNull Context context) {
        this(context, null);
    }

    public MusicSettingView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);

        init();
    }

    private void init() {
        View rootView = LayoutInflater.from(getContext()).inflate(R.layout.room_music_settings_layout,
                this, true);
        mBgmGrid = rootView.findViewById(R.id.bgm_grid);
        GridView soundGrid = rootView.findViewById(R.id.sound_grid);
        AppCompatSeekBar bgmSeeBar = findViewById(R.id.bgm_volume_seek_bar);
        AppCompatSeekBar soundSeeBar = findViewById(R.id.sound_volume_bar);

        mBgmAdapter = new MusicSettingAdapter(getContext(), true);
        mBgmAdapter.setVolume(bgmSeeBar.getProgress());
        mBgmGrid.setAdapter(mBgmAdapter);

        mSoundAdapter = new MusicSettingAdapter(getContext(), false);
        mSoundAdapter.setVolume(soundSeeBar.getProgress());
        soundGrid.setAdapter(mSoundAdapter);

        bgmSeeBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                mBgmAdapter.setVolume(progress);
                PanoRtcMgr.getInstance().updateVolume(progress, true);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

        soundSeeBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                mSoundAdapter.setVolume(progress);
                PanoRtcMgr.getInstance().updateVolume(progress, false);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
    }

    public void refreshPlayingBgmItem(int position) {
        mBgmAdapter.setSelectedItem((TextView) mBgmGrid.getChildAt(position), position);
    }
}
