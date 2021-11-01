package video.pano.audiochat.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.ListView;

import androidx.annotation.Nullable;

import video.pano.audiochat.R;
import video.pano.audiochat.adapter.VoiceChangeAdapter;

public class VoiceChaneListActivity extends BaseActivity {

    public static void start(Activity activity) {
        activity.startActivity(new Intent(activity, VoiceChaneListActivity.class));
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_voice_change_list);

        ListView listView = findViewById(R.id.voice_list);
        listView.setAdapter(new VoiceChangeAdapter(getApplicationContext()));
    }
}
