package video.pano.audiochat.rtc;

import static com.pano.rtc.api.Constants.PanoOptionType.AudioAutoGainControl;
import static com.pano.rtc.api.Constants.PanoOptionType.AudioNoiseSuppressionLevel;
import static com.pano.rtc.api.Constants.PanoOptionType.AudioPreProcessMode;

import android.content.Context;

import com.pano.rtc.api.Constants;
import com.pano.rtc.api.RtcEngine;
import com.pano.rtc.api.RtcEngineCallback;
import com.pano.rtc.api.RtcEngineConfig;

import video.pano.audiochat.activity.SettingActivity;
import video.pano.audiochat.utils.SPUtil;
import video.pano.audiochat.utils.Utils;

public class PanoRtcEngine {

    private static RtcEngine mRtcEngine;

    public static RtcEngine getInstance() {
        if (mRtcEngine == null ) {
            synchronized (PanoRtcEngine.class) {
                if (mRtcEngine == null ) {
                    createEngine();
                }
            }
        }
        return mRtcEngine;
    }

    public static void refresh(boolean audioPreProcess) {
        mRtcEngine.destroy();
        boolean audioHighQuality = (boolean) SPUtil.getValue(
                Utils.getApp(),
                SettingActivity.KEY_AUDIO_HIGH_QUALITY,
                false);
        createEngine(audioPreProcess, audioHighQuality ? 1 : 0);
    }

    public static void refresh(int audioHighQuality) {
        mRtcEngine.destroy();
        boolean audioPreProcess = (boolean) SPUtil.getValue(
                Utils.getApp(),
                SettingActivity.KEY_AUDIO_PRE_PROCESS,
                false);
        createEngine(audioPreProcess,audioHighQuality);
    }

    public static void clear(){
        mRtcEngine.destroy();
        mRtcEngine = null ;
    }

    private static void createEngine(){
        boolean audioPreProcess = (boolean) SPUtil.getValue(
                Utils.getApp(),
                SettingActivity.KEY_AUDIO_PRE_PROCESS,
                false);
        boolean audioHighQuality = (boolean) SPUtil.getValue(
                Utils.getApp(),
                SettingActivity.KEY_AUDIO_HIGH_QUALITY,
                false);
        createEngine(audioPreProcess,audioHighQuality ? 1 : 0);
    }

    private static void createEngine(boolean audioPreProcess,int audioScenario) {
        try {
            if (audioPreProcess) {
                mRtcEngine = RtcEngine.create(getConfig(
                        Utils.getApp(),
                        Constants.AudioAecType.Default,
                        audioScenario,
                        PanoRtcMgr.getInstance().getPanoRtcHandler()));
                mRtcEngine.setOption(AudioNoiseSuppressionLevel,
                        Constants.AudioNoiseSuppressionLevelOption.Default);
                mRtcEngine.setOption(AudioAutoGainControl,
                        Constants.AudioAutoGainControlOption.Default);
                mRtcEngine.setOption(AudioPreProcessMode,
                        Constants.AudioPreProcessModeOption.Default);
            } else {
                mRtcEngine = RtcEngine.create(getConfig(
                        Utils.getApp(),
                        Constants.AudioAecType.Off,
                        audioScenario,
                        PanoRtcMgr.getInstance().getPanoRtcHandler()));
                mRtcEngine.setOption(AudioNoiseSuppressionLevel,
                        Constants.AudioNoiseSuppressionLevelOption.Disable);
                mRtcEngine.setOption(AudioAutoGainControl,
                        Constants.AudioAutoGainControlOption.Disable);
                mRtcEngine.setOption(AudioPreProcessMode,
                        Constants.AudioPreProcessModeOption.Disable);
            }
            mRtcEngine.setOption(Constants.PanoOptionType.AudioVoiceChangerMode,
                    PanoRtcMgr.getInstance().getLastAudioVoiceChangerOption());
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    private static RtcEngineConfig getConfig(Context context, Constants.AudioAecType audioAecType,int audioScenario ,
                                             RtcEngineCallback callback) {
        RtcEngineConfig engineConfig = new RtcEngineConfig();
        engineConfig.appId = PanoConfig.APPID;
        engineConfig.server = PanoConfig.PANO_SERVER;
        engineConfig.context = context;
        engineConfig.callback = callback;
        engineConfig.audioScenario = audioScenario ;
        // ??????????????????
        engineConfig.audioAecType = audioAecType;
        // ????????????
        engineConfig.videoCodecHwAcceleration = true;
        return engineConfig;
    }
}
