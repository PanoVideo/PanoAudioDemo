package video.pano.audiochat.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;

import androidx.annotation.Nullable;

import video.pano.audiochat.R;
import video.pano.audiochat.rtc.PanoRtcEngine;
import video.pano.audiochat.rtc.PanoRtcMgr;
import video.pano.audiochat.rtc.data.PanoMsgFactory;

public class AudioLogUploadActivity extends BaseActivity {

    private EditText mDesEdit;

    public static void start(Activity activity) {
        activity.startActivity(new Intent(activity, AudioLogUploadActivity.class));
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_audio_log_upload);

        mDesEdit = findViewById(R.id.audio_log_upload_content);
    }

    public void onClickUpload(View view) {

        PanoRtcEngine.getInstance().getMessageService().broadcastMessage(PanoMsgFactory.uploadAudioLogMsg(), true);
        PanoRtcMgr.getInstance().setAudioLogDes(mDesEdit.getText().toString());
        finish();
    }

}
