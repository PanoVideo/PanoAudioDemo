package video.pano.audiochat.activity;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.app.ActivityCompat.OnRequestPermissionsResultCallback;

import com.pano.rtc.api.RtcEngine;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import video.pano.audiochat.R;
import video.pano.audiochat.rtc.PanoConfig;
import video.pano.audiochat.utils.SPUtil;
import video.pano.audiochat.view.CommonTitle;

public class StartChatRoomActivity extends AppCompatActivity implements OnRequestPermissionsResultCallback {

    private static final int PERMISSION_REQUEST_CODE = 1;
    private static final String TAG_CREATE = "isCreate";
    private boolean mIsCreate;
    private EditText mRoomIdEdit;
    private EditText mUserNameEdit;

    public static void start(Activity activity, boolean isCreate) {
        Intent intent = new Intent(activity, StartChatRoomActivity.class);
        intent.putExtra(TAG_CREATE, isCreate);
        activity.startActivity(intent);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_start_chat_room);

        mIsCreate = getIntent().getBooleanExtra(TAG_CREATE, true);

        mRoomIdEdit = findViewById(R.id.room_id_edit);
        mUserNameEdit = findViewById(R.id.user_name_edit);
        mUserNameEdit.setText((String) SPUtil.getValue(this, SPUtil.KEY_USER_NAME, ""));

        CommonTitle commonTitle = findViewById(R.id.create_chat_room_title);
        TextView startBtn = findViewById(R.id.start_btn);
        if (mIsCreate) {
            commonTitle.setTitle(R.string.create_chat_room);
            startBtn.setText(R.string.room_create);
        } else {
            commonTitle.setTitle(R.string.join_chat_room);
            startBtn.setText(R.string.room_join);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (RtcEngine.checkPermission(this).size() == 0) {
                startChatRoom();
            } else {
                Toast.makeText(StartChatRoomActivity.this, "Some permissions are denied", Toast.LENGTH_LONG).show();
            }
        } else {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }

    public void onClickStart(View view) {

        if (TextUtils.isEmpty(mRoomIdEdit.getText().toString())) {
            Toast.makeText(this, R.string.room_id_empty_warning, Toast.LENGTH_SHORT).show();
            return;
        }

        if (TextUtils.isEmpty(mUserNameEdit.getText().toString())) {
            Toast.makeText(this, R.string.room_name_empty_warning, Toast.LENGTH_SHORT).show();
            return;
        }

        if (checkPermissions()) {
            startChatRoom();
        }
    }

    private boolean checkPermissions() {
        final List<String> missed = RtcEngine.checkPermission(this);
        if (missed.size() > 0) {

            List<String> showRationale = new ArrayList<>();
            for (String permission : missed) {
                if (ActivityCompat.shouldShowRequestPermissionRationale(this, permission)) {
                    showRationale.add(permission);
                }
            }

            if (showRationale.size() > 0) {
                new AlertDialog.Builder(StartChatRoomActivity.this)
                        .setTitle(R.string.tips)
                        .setMessage(R.string.permission_request_message)
                        .setPositiveButton(R.string.ok, (dialog, which) -> {
                            ActivityCompat.requestPermissions(this,
                                    missed.toArray(new String[0]),
                                    PERMISSION_REQUEST_CODE);
                        })
                        .setNegativeButton(R.string.cancel, null)
                        .create()
                        .show();
            } else {
                ActivityCompat.requestPermissions(this, missed.toArray(new String[0]), PERMISSION_REQUEST_CODE);
            }
            return false;
        }
        return true;
    }

    private void startChatRoom() {
        String roomId = mRoomIdEdit.getText().toString();
        String userName = mUserNameEdit.getText().toString();
        long userId = 10000 + new Random().nextInt(5000);
        ChatRoomActivity.start(this, roomId, userName, userId, PanoConfig.TOKEN, mIsCreate);
    }

}
