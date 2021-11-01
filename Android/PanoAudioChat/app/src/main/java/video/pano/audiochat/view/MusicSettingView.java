package video.pano.audiochat.view;

import android.content.Context;
import android.graphics.Color;
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
import video.pano.audiochat.model.Song;
import video.pano.audiochat.rtc.PanoRtcMgr;

public class MusicSettingView extends ConstraintLayout implements PanoRtcMgr.BgmPlayCallback{

    private GridView mBgmGrid;
    private MusicSettingAdapter mBgmAdapter;
    private MusicSettingAdapter mSoundAdapter;
    private MusicSettingCallback mMusicSettingCallback;
    private TextView mBgmLocalSong;
    private Song mLocalSong;

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
        mBgmLocalSong = rootView.findViewById(R.id.tv_bgm_local_song);
        mBgmLocalSong.setOnClickListener(v -> {
            if(mLocalSong == null) return ;
            playLocalMusicBgm();
        });

        mBgmAdapter = new MusicSettingAdapter(getContext(), true);
        mBgmAdapter.setVolume(bgmSeeBar.getProgress());
        mBgmGrid.setAdapter(mBgmAdapter);

        mSoundAdapter = new MusicSettingAdapter(getContext(), false);
        mSoundAdapter.setVolume(soundSeeBar.getProgress());
        soundGrid.setAdapter(mSoundAdapter);

        PanoRtcMgr.getInstance().setBgmPlayCallback(this);

        rootView.findViewById(R.id.bgm_local_music).setOnClickListener(v -> {
            if(mMusicSettingCallback != null){
                mMusicSettingCallback.onClickLocalSong();
            }
        });

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

    public void setLocalSong(Song localSong){
        if(localSong == null) return ;
        mLocalSong = localSong;
        mBgmLocalSong.setVisibility(View.VISIBLE);
        mBgmLocalSong.setText(localSong.name);

        mBgmLocalSong.setBackgroundResource(R.drawable.bgm_item_bg_blue);
        mBgmLocalSong.setTextColor(Color.WHITE);
        PanoRtcMgr.getInstance().playBgm(mLocalSong.getLocalSongPath());
    }

    public void refreshPlayingBgmItem(int position) {
        mBgmAdapter.setSelectedItem(position);
    }

    public void setMicInviteCallback(MusicSettingCallback callback) {
        mMusicSettingCallback = callback;
    }

    private void playLocalMusicBgm(){
        if(PanoRtcMgr.getInstance().isPlayingBgm()
                && PanoRtcMgr.getInstance().getCurrentBgmPos() == PanoRtcMgr.LOCAL_SONG_BGM_POS){
            mBgmLocalSong.setBackgroundResource(R.drawable.bgm_item_bg_white);
            mBgmLocalSong.setTextColor(getResources().getColor(R.color.color_333));
            PanoRtcMgr.getInstance().destroyBgmMusic();
        }else{
            mBgmLocalSong.setBackgroundResource(R.drawable.bgm_item_bg_blue);
            mBgmLocalSong.setTextColor(Color.WHITE);
            PanoRtcMgr.getInstance().playBgm(mLocalSong.getLocalSongPath());
        }
    }

    @Override
    public void onBgmPlay(int position) {
        if(position == PanoRtcMgr.LOCAL_SONG_BGM_POS){
            if(mBgmAdapter != null) mBgmAdapter.setSelectedItem(position);
            mBgmLocalSong.setBackgroundResource(R.drawable.bgm_item_bg_blue);
            mBgmLocalSong.setTextColor(Color.WHITE);
        }else{
            mBgmLocalSong.setBackgroundResource(R.drawable.bgm_item_bg_white);
            mBgmLocalSong.setTextColor(getResources().getColor(R.color.color_333));
        }
    }

    public interface MusicSettingCallback {
        void onClickLocalSong();
    }
}
