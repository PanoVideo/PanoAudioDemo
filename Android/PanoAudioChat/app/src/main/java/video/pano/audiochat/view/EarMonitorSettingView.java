package video.pano.audiochat.view;

import android.content.Context;
import android.media.AudioDeviceInfo;
import android.media.AudioManager;
import android.os.Build;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatSeekBar;
import androidx.appcompat.widget.SwitchCompat;
import androidx.constraintlayout.widget.ConstraintLayout;

import video.pano.audiochat.PACApplication;
import video.pano.audiochat.R;
import video.pano.audiochat.rtc.PanoRtcEngine;

public class EarMonitorSettingView extends ConstraintLayout {

    private SwitchCompat mEarMonitorSwitch;
    private AppCompatSeekBar mVolumeSeekBar;
    private TextView mCancelTv;
    private EarMonitorSettingCallback mCallback;

    public EarMonitorSettingView(@NonNull Context context) {
        this(context, null);
    }

    public EarMonitorSettingView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);

        View rootView = LayoutInflater.from(getContext()).inflate(
                R.layout.room_ear_monitor_pupup_layout, this, true);
        mEarMonitorSwitch = rootView.findViewById(R.id.ear_monitor_switch);
        mVolumeSeekBar = rootView.findViewById(R.id.ear_return_volume);
        mCancelTv = rootView.findViewById(R.id.cancel);
        mCancelTv.setOnClickListener(v -> {
            if (mCallback != null) {
                mCallback.onEarMonitorSettingCancel();
            }
        });

        mEarMonitorSwitch.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (mEarMonitorSwitch.isChecked()) {
                if (isWiredHeadsetOn()) {
                    PanoRtcEngine.getInstance().setAudioEarMonitoring(true);
                    PanoRtcEngine.getInstance().setPlayoutDeviceVolume(mVolumeSeekBar.getProgress());
                    PanoRtcEngine.getInstance().setRecordDeviceVolume(mVolumeSeekBar.getProgress());
                } else {
                    PanoRtcEngine.getInstance().setAudioEarMonitoring(false);
                    Toast.makeText(context, R.string.room_ear_monitor_tips, Toast.LENGTH_SHORT).show();
                    mEarMonitorSwitch.setChecked(false);
                }

            } else {
                PanoRtcEngine.getInstance().setAudioEarMonitoring(false);
            }
        });

        mVolumeSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (isWiredHeadsetOn()) {
                    PanoRtcEngine.getInstance().setPlayoutDeviceVolume(progress);
                    PanoRtcEngine.getInstance().setRecordDeviceVolume(progress);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
    }

    private boolean isWiredHeadsetOn() {
        AudioManager audioManager = (AudioManager) PACApplication.getInstance().getSystemService(Context.AUDIO_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            AudioDeviceInfo[] devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS);
            for (AudioDeviceInfo device : devices) {
                int deviceType = device.getType();
                if (deviceType == AudioDeviceInfo.TYPE_WIRED_HEADSET
                        || deviceType == AudioDeviceInfo.TYPE_WIRED_HEADPHONES
                        || deviceType == AudioDeviceInfo.TYPE_USB_DEVICE
                        || deviceType == AudioDeviceInfo.TYPE_USB_HEADSET
                        || deviceType == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP
                        || deviceType == AudioDeviceInfo.TYPE_BLUETOOTH_SCO) {
                    return true;
                }
            }
        } else {
            return audioManager.isWiredHeadsetOn()
                    || audioManager.isBluetoothScoOn()
                    || audioManager.isBluetoothA2dpOn();
        }
        return false;
    }

    public void setEarMonitorSettingCallback(EarMonitorSettingCallback callback) {
        mCallback = callback;
    }

    public interface EarMonitorSettingCallback {
        void onEarMonitorSettingCancel();
    }
}
