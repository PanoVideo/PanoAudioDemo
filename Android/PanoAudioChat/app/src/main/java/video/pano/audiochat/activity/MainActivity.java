package video.pano.audiochat.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.Nullable;

import video.pano.audiochat.R;
import video.pano.audiochat.utils.Utils;

public class MainActivity extends BaseActivity {


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    public void onClickCreate(View view) {
        if(!Utils.doubleClick()){
            StartChatRoomActivity.start(this, true);
        }
    }

    public void onClickJoin(View view) {
        if(!Utils.doubleClick()){
            StartChatRoomActivity.start(this, false);
        }
    }

    public void onClickSetting(View view) {
        if(!Utils.doubleClick()){
            SettingActivity.start(this);
        }
    }

    public static void launch(Activity activity){
        Intent intent = new Intent(activity,MainActivity.class);
        activity.startActivity(intent);
    }
}
