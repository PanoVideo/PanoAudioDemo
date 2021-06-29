package video.pano.audiochat.activity;

import android.os.Bundle;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import video.pano.audiochat.R;
import video.pano.audiochat.utils.SPUtil;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        checkAppUpdate();
    }

    public void onClickCreate(View view) {
        StartChatRoomActivity.start(this, true);
    }

    public void onClickJoin(View view) {
        StartChatRoomActivity.start(this, false);
    }

    public void onClickSetting(View view) {
        SettingActivity.start(this);
    }

    /**
     * 更新逻辑
     */
    public void checkAppUpdate() {
    }
}
