package video.pano.audiochat.activity;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.SwitchCompat;

import video.pano.audiochat.BuildConfig;
import video.pano.audiochat.R;
import video.pano.audiochat.rtc.PanoRtcEngine;
import video.pano.audiochat.rtc.PanoRtcMgr;
import video.pano.audiochat.utils.SPUtil;

public class SettingActivity extends AppCompatActivity {

    public static final String KEY_AUDIO_PRE_PROCESS = "audio_pre_process";
    private SwitchCompat mDebugModeSwitch;
    private SwitchCompat mAudioPreProcessSwitch;
    private EditText mUserNameEdit;

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
        setAudioAudioPreProcessSwitch();
        setVersionName();
    }

    private void setUserNameEdit() {
        mUserNameEdit = findViewById(R.id.user_name_edit);
        mUserNameEdit.setText((String) SPUtil.getValue(this, SPUtil.KEY_USER_NAME, ""));
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

    private void setAudioAudioPreProcessSwitch() {
        mAudioPreProcessSwitch = findViewById(R.id.audio_pre_process_mode_switch);
        mAudioPreProcessSwitch.setChecked((boolean) SPUtil.getValue(this, KEY_AUDIO_PRE_PROCESS, false));
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
        FeedbackActivity.start(this);
    }

    public void onClickVoiceChange(View view) {
        VoiceChaneListActivity.start(this);
    }

    public void onClickUploadAudioLog(View view) {
        AudioLogUploadActivity.start(this);
    }

    @Override
    protected void onPause() {
        SPUtil.setValue(this, SPUtil.KEY_USER_NAME, mUserNameEdit.getText().toString());
        super.onPause();
    }
}
