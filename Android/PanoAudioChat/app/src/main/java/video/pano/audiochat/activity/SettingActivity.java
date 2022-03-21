package video.pano.audiochat.activity;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.SwitchCompat;

import video.pano.audiochat.BuildConfig;
import video.pano.audiochat.R;
import video.pano.audiochat.rtc.PanoRtcEngine;
import video.pano.audiochat.rtc.PanoRtcMgr;
import video.pano.audiochat.utils.SPUtil;
import video.pano.audiochat.utils.Utils;

public class SettingActivity extends BaseActivity {

    public static final String KEY_AUDIO_PRE_PROCESS = "audio_pre_process";
    public static final String KEY_AUDIO_HIGH_QUALITY = "audio_high_quality";
    private SwitchCompat mDebugModeSwitch;
    private SwitchCompat mAudioPreProcessSwitch;
    private SwitchCompat mAudioHighQualitySwitch;
    private TextView mUserNameText;

    public static void start(Activity activity) {
        activity.startActivity(new Intent(activity, SettingActivity.class));
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_setting);

        init();
    }

    private void init() {
        setUserNameEdit();
        setDebugModeSwitch();
        setAudioHighQualitySwitch();
        setAudioAudioPreProcessSwitch();
        setVersionName();
    }

    private void setUserNameEdit() {
        mUserNameText = findViewById(R.id.user_name_edit);
        mUserNameText.setText((String) SPUtil.getValue(this, SPUtil.KEY_USER_NAME, ""));
    }

    private void setDebugModeSwitch() {
        mDebugModeSwitch = findViewById(R.id.debug_mode_switch);
        mDebugModeSwitch.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (mDebugModeSwitch.isChecked()) {
                Dialog alertDialog = new AlertDialog.Builder(SettingActivity.this)
                        .setTitle(R.string.tips)
                        .setMessage(R.string.setting_debug_mode_tip)
                        .setNegativeButton(R.string.cancel, (dialog, which) -> {
                            mDebugModeSwitch.setChecked(false);
                            PanoRtcEngine.getInstance().enableUploadDebugLogs(false);
                        })
                        .setPositiveButton(R.string.ok, (dialog, which) -> {
                            mDebugModeSwitch.setChecked(true);
                            PanoRtcEngine.getInstance().enableUploadDebugLogs(true);
                        })
                        .create();
                alertDialog.show();
            }
        });
    }

    private void setAudioHighQualitySwitch() {
        mAudioHighQualitySwitch = findViewById(R.id.audio_high_quality_mode_switch);
        mAudioHighQualitySwitch.setChecked((boolean) SPUtil.getValue(this, KEY_AUDIO_HIGH_QUALITY, false));
        mAudioHighQualitySwitch.setOnCheckedChangeListener((buttonView, isChecked) -> {

            if (PanoRtcMgr.getInstance().inRoom()) {
                Toast.makeText(this, R.string.setting_audio_pre_process_warning,
                        Toast.LENGTH_SHORT).show();
                mAudioHighQualitySwitch.setChecked(!isChecked);
            } else {
                PanoRtcEngine.refresh(isChecked ? 1 : 0);
            }
            SPUtil.setValue(this, KEY_AUDIO_HIGH_QUALITY, isChecked);
        });
    }

    private void setAudioAudioPreProcessSwitch() {
        mAudioPreProcessSwitch = findViewById(R.id.audio_pre_process_mode_switch);
        mAudioPreProcessSwitch.setChecked((boolean) SPUtil.getValue(this, KEY_AUDIO_PRE_PROCESS, true));
        mAudioPreProcessSwitch.setOnCheckedChangeListener((buttonView, isChecked) -> {

            if (PanoRtcMgr.getInstance().inRoom()) {
                Toast.makeText(this, R.string.setting_audio_pre_process_warning,
                        Toast.LENGTH_SHORT).show();
                mAudioPreProcessSwitch.setChecked(!isChecked);
            } else {
                PanoRtcEngine.refresh(isChecked);
            }
            SPUtil.setValue(this, KEY_AUDIO_PRE_PROCESS, isChecked);
        });
    }

    private void setVersionName() {
        TextView versionNameTv = findViewById(R.id.app_version_des);
        versionNameTv.setText("v" + BuildConfig.VERSION_NAME + "("
                + PanoRtcEngine.getInstance().getSdkVersion() + ")");
    }

    public void onClickSendFeedback(View view) {
        if(!Utils.doubleClick()){
            FeedbackActivity.start(this);
        }
    }

    public void onClickVoiceChange(View view) {
        if(!Utils.doubleClick()){
            VoiceChaneListActivity.start(this);
        }
    }

    public void onClickUploadAudioLog(View view) {
        if(!Utils.doubleClick()){
            AudioLogUploadActivity.start(this);
        }
    }

    @Override
    protected void onPause() {
        SPUtil.setValue(this, SPUtil.KEY_USER_NAME, mUserNameText.getText().toString());
        super.onPause();
    }
}
