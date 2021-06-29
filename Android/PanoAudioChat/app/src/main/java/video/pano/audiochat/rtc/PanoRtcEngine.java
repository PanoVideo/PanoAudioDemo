package video.pano.audiochat.rtc;

import android.content.Context;

import com.pano.rtc.api.Constants;
import com.pano.rtc.api.RtcEngine;
import com.pano.rtc.api.RtcEngineCallback;
import com.pano.rtc.api.RtcEngineConfig;

import video.pano.audiochat.PACApplication;
import video.pano.audiochat.activity.SettingActivity;
import video.pano.audiochat.utils.SPUtil;

import static com.pano.rtc.api.Constants.PanoOptionType.AudioAutoGainControl;
import static com.pano.rtc.api.Constants.PanoOptionType.AudioNoiseSuppressionLevel;
import static com.pano.rtc.api.Constants.PanoOptionType.AudioPreProcessMode;

public class PanoRtcEngine {

    private static RtcEngine mRtcEngine;

    public static RtcEngine getInstance() {
        if (mRtcEngine == null ) {
            synchronized (PanoRtcEngine.class) {
                if (mRtcEngine == null ) {
                    boolean audioPreProcess = (boolean) SPUtil.getValue(
                            PACApplication.getInstance(),
                            SettingActivity.KEY_AUDIO_PRE_PROCESS,
                            false);
                    createEngine(audioPreProcess);
                }
            }
        }
        return mRtcEngine;
    }

    public static void refresh(boolean audioPreProcess) {
        RtcEngine.destroy();
        createEngine(audioPreProcess);
    }

    public static void clear(){
        RtcEngine.destroy();
        mRtcEngine = null ;
    }

    private static void createEngine(boolean audioPreProcess) {
        try {
            if (audioPreProcess) {
                mRtcEngine = RtcEngine.create(getConfig(
                        PACApplication.getInstance(),
                        Constants.AudioAecType.Default,
                        PanoRtcMgr.getInstance().getPanoRtcHandler()));
                mRtcEngine.setOption(AudioNoiseSuppressionLevel,
                        Constants.AudioNoiseSuppressionLevelOption.Default);
                mRtcEngine.setOption(AudioAutoGainControl,
                        Constants.AudioAutoGainControlOption.Default);
                mRtcEngine.setOption(AudioPreProcessMode,
                        Constants.AudioPreProcessModeOption.Default);


            } else {
                mRtcEngine = RtcEngine.create(getConfig(
                        PACApplication.getInstance(),
                        Constants.AudioAecType.Off,
                        PanoRtcMgr.getInstance().getPanoRtcHandler()));
                mRtcEngine.setOption(AudioNoiseSuppressionLevel,
                        Constants.AudioNoiseSuppressionLevelOption.Disable);
                mRtcEngine.setOption(AudioAutoGainControl,
                        Constants.AudioAutoGainControlOption.Disable);
                mRtcEngine.setOption(AudioPreProcessMode,
                        Constants.AudioPreProcessModeOption.Disable);
            }
            PanoRtcEngine.getInstance().setOption(Constants.PanoOptionType.AudioVoiceChangerMode,
                    PanoRtcMgr.getInstance().getLastAudioVoiceChangerOption());
        } catch (Exception e) {

        }

    }

    private static RtcEngineConfig getConfig(Context context, Constants.AudioAecType audioAecType,
                                             RtcEngineCallback callback) {
        RtcEngineConfig engineConfig = new RtcEngineConfig();
        engineConfig.appId = PanoConfig.APPID;
        engineConfig.server = PanoConfig.PANO_SERVER;
        engineConfig.context = context;
        engineConfig.callback = callback;
        // 回音消除算法
        engineConfig.audioAecType = audioAecType;
        // 硬件加速
        engineConfig.videoCodecHwAcceleration = true;
        return engineConfig;
    }
}
