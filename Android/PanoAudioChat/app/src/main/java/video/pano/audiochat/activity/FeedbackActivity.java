package video.pano.audiochat.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.RadioGroup;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.SwitchCompat;

import com.pano.rtc.api.Constants;
import com.pano.rtc.api.RtcEngine;

import video.pano.audiochat.R;
import video.pano.audiochat.rtc.PanoConfig;
import video.pano.audiochat.rtc.PanoRtcEngine;

public class FeedbackActivity extends AppCompatActivity {

    private RadioGroup mRadioGroup;
    private EditText mDesEdit;
    private EditText mContactEdit;
    private SwitchCompat mUploadLogSwitch;

    public static void start(Activity activity) {
        activity.startActivity(new Intent(activity, FeedbackActivity.class));
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_feedback);

        mRadioGroup = findViewById(R.id.problem_type_tab);
        mDesEdit = findViewById(R.id.feedback_des_edit);
        mContactEdit = findViewById(R.id.contact_edit);
        mUploadLogSwitch = findViewById(R.id.upload_log_switch);
    }

    public void onClickSend(View view) {
        RtcEngine.FeedbackInfo info = new RtcEngine.FeedbackInfo();
        info.type = mRadioGroup.getCheckedRadioButtonId() == R.id.voice_btn ?
                Constants.FeedbackType.Audio : Constants.FeedbackType.General;
        info.productName = PanoConfig.PRODUCT_NAME;
        info.description = mDesEdit.getText().toString();
        info.contact = mContactEdit.getText().toString();
        info.uploadLogs = mUploadLogSwitch.isChecked();
        PanoRtcEngine.getInstance().sendFeedback(info);
        finish();
    }

}
