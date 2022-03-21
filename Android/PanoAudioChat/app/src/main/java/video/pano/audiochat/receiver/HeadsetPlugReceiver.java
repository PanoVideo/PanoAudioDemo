package video.pano.audiochat.receiver;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import video.pano.audiochat.PACApplication;
import video.pano.audiochat.rtc.PanoRtcEngine;
import video.pano.audiochat.utils.Utils;

public class HeadsetPlugReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.hasExtra("state")) {
            if (intent.getIntExtra("state", 0) == 0) {
                PanoRtcEngine.getInstance().setAudioEarMonitoring(false);
            }
            ((PACApplication)Utils.getApp())
                    .updateHeadsetPlug(intent.getIntExtra("state", 0) == 1);
        }
    }
}
