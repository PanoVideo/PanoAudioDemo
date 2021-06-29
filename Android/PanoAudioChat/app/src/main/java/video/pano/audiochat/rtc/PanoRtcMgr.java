package video.pano.audiochat.rtc;

import com.pano.rtc.api.Constants;
import com.pano.rtc.api.RtcAudioMixingConfig;
import com.pano.rtc.api.RtcEngine;

import video.pano.audiochat.PACApplication;
import video.pano.audiochat.adapter.VoiceChangeAdapter;
import video.pano.audiochat.utils.AssetUtil;
import video.pano.audiochat.utils.SPUtil;

public class PanoRtcMgr {

    private PanoRtcHandler mPanoRtcHandler;

    private String mAudioLogDes;
    private long mTaskId = 0;
    private long mCurrentBgmTaskId = -1;
    private long mCurrentSoundTaskId = -1;
    private BgmCallback mBgmCallback;
    private boolean mIsPlayingBgm;
    private int mCurrentBgmPos = 0;
    private int mCurrentBgmVolume = 100;
    private boolean mInRoom = false;

    private static class Holder {
        private static final PanoRtcMgr INSTANCE = new PanoRtcMgr();
    }

    public static PanoRtcMgr getInstance() {
        return Holder.INSTANCE;
    }

    private PanoRtcMgr() {
        mPanoRtcHandler = new PanoRtcHandler();
    }

    public void setInRoom(boolean inRoom) {
        mInRoom = inRoom;
    }

    public boolean inRoom() {
        return mInRoom;
    }



    public PanoRtcHandler getPanoRtcHandler() {
        return mPanoRtcHandler;
    }

    public void addPanoEventListener(PanoEvent panoEvent) {
        mPanoRtcHandler.addListener(panoEvent);
    }

    public void removePanoEventListener(PanoEvent panoEvent) {
        mPanoRtcHandler.removeListener(panoEvent);
    }

    public void setAudioLogDes(String des) {
        mAudioLogDes = des;
    }

    public void sendAudioLog() {
        RtcEngine.FeedbackInfo info = new RtcEngine.FeedbackInfo();
        info.type = Constants.FeedbackType.Audio;
        info.productName = PanoConfig.PRODUCT_NAME;
        info.description = mAudioLogDes;
        info.contact = "";
        info.uploadLogs = true;
        PanoRtcEngine.getInstance().sendFeedback(info);
    }

    public void pauseBgm() {
        mIsPlayingBgm = false;
        PanoRtcEngine.getInstance().getAudioMixingMgr().pauseAudioMixing(mCurrentBgmTaskId);
        if (mBgmCallback != null) {
            mBgmCallback.onBgmPause();
        }
    }

    public void resumeBgm() {
        mIsPlayingBgm = true;
        PanoRtcEngine.getInstance().getAudioMixingMgr().resumeAudioMixing(mCurrentBgmTaskId);
        if (mBgmCallback != null) {
            mBgmCallback.onBgmPause();
        }
        if (mBgmCallback != null) {
            mBgmCallback.onBgmResume();
        }
    }

    public void playBgm() {

        if (mCurrentBgmTaskId > -1) {
            resumeBgm();
        } else {
            playBgm(mCurrentBgmPos, mCurrentBgmVolume);
        }
        if (mBgmCallback != null) {
            mBgmCallback.onBgmPlay(mCurrentBgmPos);
        }
    }

    public void playNextBgm() {
        mCurrentBgmPos++;
        if (mCurrentBgmPos == AssetUtil.OUT_BGM_FILE_NAME.length) {
            mCurrentBgmPos = 0;
        }
        playBgm(mCurrentBgmPos, mCurrentBgmVolume);
        if (mBgmCallback != null) {
            mBgmCallback.onBgmPlay(mCurrentBgmPos);
        }
    }

    public void playBgm(int position, int volume) {
        if (mCurrentBgmTaskId > -1) {
            PanoRtcEngine.getInstance().getAudioMixingMgr().destroyAudioMixingTask(mCurrentBgmTaskId);
        }
        PanoRtcEngine.getInstance().getAudioMixingMgr().createAudioMixingTask(mTaskId,
                AssetUtil.OUT_BGM_FILE_NAME[position]);
        RtcAudioMixingConfig config = new RtcAudioMixingConfig();
        config.cycle = 0;
        config.publishVolume = volume;
        config.loopbackVolume = volume;
        PanoRtcEngine.getInstance().getAudioMixingMgr().startAudioMixingTask(mTaskId, config);

        mCurrentBgmTaskId = mTaskId++;
        mIsPlayingBgm = true;
        mCurrentBgmPos = position;
        mCurrentBgmVolume = volume;
    }

    public void playSound(int position, int volume) {
        if (mCurrentSoundTaskId > -1) {
            PanoRtcEngine.getInstance().getAudioMixingMgr()
                    .destroyAudioMixingTask(mCurrentSoundTaskId);
        }

        PanoRtcEngine.getInstance().getAudioMixingMgr().createAudioMixingTask(mTaskId,
                AssetUtil.OUT_SOUND_FILE_NAME[position]);
        RtcAudioMixingConfig config = new RtcAudioMixingConfig();
        config.cycle = 1;
        config.publishVolume = volume;
        config.loopbackVolume = volume;
        PanoRtcEngine.getInstance().getAudioMixingMgr().startAudioMixingTask(mTaskId, config);

        mCurrentSoundTaskId = mTaskId++;
    }

    public void destroyBgmMusic() {
        if (mCurrentBgmTaskId > -1) {
            PanoRtcEngine.getInstance().getAudioMixingMgr().destroyAudioMixingTask(mCurrentBgmTaskId);
        }
        mCurrentBgmTaskId = -1;
        mIsPlayingBgm = false;
        if (mBgmCallback != null) {
            mBgmCallback.onBgmDestroy();
        }
    }

    public void updateVolume(int volume, boolean loop) {
        if (mCurrentBgmTaskId > -1) {
            RtcAudioMixingConfig config = new RtcAudioMixingConfig();
            config.publishVolume = volume;
            config.loopbackVolume = volume;
            config.cycle = loop ? 0 : 1;
            PanoRtcEngine.getInstance().getAudioMixingMgr().updateAudioMixingTask(mCurrentBgmTaskId, config);
        }
    }

    public boolean isPlayingBgm() {
        return mIsPlayingBgm;
    }

    public void setBgmCallback(BgmCallback callback) {
        mBgmCallback = callback;
    }

    public void clearMusicCallback() {
        mBgmCallback = null;
    }

    public void leaveRoom() {

        destroyBgmMusic();
    }

    public Constants.AudioVoiceChangerOption getLastAudioVoiceChangerOption() {
        int position = (int) SPUtil.getValue(PACApplication.getInstance(),
                VoiceChangeAdapter.KEY_LAST_SELECTED_VOICE, 0);
        return getAudioVoiceChangerOption(position);
    }

    public Constants.AudioVoiceChangerOption getAudioVoiceChangerOption(int position) {

        Constants.AudioVoiceChangerOption vcOption;
        switch (position) {
            case 1:
                vcOption = Constants.AudioVoiceChangerOption.Monster;
                break;
            case 2:
                vcOption = Constants.AudioVoiceChangerOption.Male;
                break;
            case 3:
                vcOption = Constants.AudioVoiceChangerOption.Female;
                break;
            case 4:
                vcOption = Constants.AudioVoiceChangerOption.Echo;
                break;
            case 5:
                vcOption = Constants.AudioVoiceChangerOption.Thriller;
                break;
            case 6:
                vcOption = Constants.AudioVoiceChangerOption.Loli;
                break;
            default:
                vcOption = Constants.AudioVoiceChangerOption.None;
                break;
        }
        return vcOption;
    }

    public interface BgmCallback {
        void onBgmDestroy();
        void onBgmPlay(int position);
        void onBgmPause();
        void onBgmResume();
    }
}
