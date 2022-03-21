package video.pano.audiochat;

import android.app.Application;
import android.content.Intent;
import android.content.IntentFilter;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import video.pano.audiochat.receiver.HeadsetPlugReceiver;
import video.pano.audiochat.rtc.PanoRtcEngine;
import video.pano.audiochat.utils.AssetUtil;
import video.pano.audiochat.utils.Utils;

public class PACApplication extends Application {

    private HeadsetPlugReceiver mReceiver;
    MutableLiveData<Boolean> mHeadsetPlug = new MutableLiveData<>();

    @Override
    public void onCreate() {
        super.onCreate();
        Utils.init(this);
        AssetUtil.init();
        mReceiver = new HeadsetPlugReceiver();
        registerReceiver(mReceiver, new IntentFilter(Intent.ACTION_HEADSET_PLUG));
    }

    public LiveData<Boolean> getHeadsetPlug() {
        return mHeadsetPlug;
    }

    public void updateHeadsetPlug(boolean plug) {
        mHeadsetPlug.postValue(plug);
    }

    @Override
    public void onTerminate() {
        super.onTerminate();
        if (mReceiver != null) unregisterReceiver(mReceiver);
        PanoRtcEngine.clear();
    }

}
