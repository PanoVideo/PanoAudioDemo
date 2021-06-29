package video.pano.audiochat;

import android.app.Application;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import com.pano.rtc.api.RtcEngine;

import video.pano.audiochat.rtc.PanoRtcEngine;
import video.pano.audiochat.utils.AssetUtil;

public class PACApplication extends Application {

    private static PACApplication sInstance;

    @Override
    public void onCreate() {
        super.onCreate();

        sInstance = this;

        AssetUtil.init();
        registerReceiver(new HeadsetPlugReceiver(), new IntentFilter(Intent.ACTION_HEADSET_PLUG));
    }

    public static PACApplication getInstance() {
        return sInstance;
    }

    private static class HeadsetPlugReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {

            if (intent.hasExtra("state")) {
                if (intent.getIntExtra("state", 0) == 0) {
                    PanoRtcEngine.getInstance().setAudioEarMonitoring(false);
                }
            }
        }
    }

    @Override
    public void onTerminate() {
        super.onTerminate();
        RtcEngine.destroy();
    }
}
