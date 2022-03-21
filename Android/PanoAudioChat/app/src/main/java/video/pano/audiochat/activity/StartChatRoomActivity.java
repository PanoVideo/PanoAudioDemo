package video.pano.audiochat.activity;

import static video.pano.audiochat.utils.SPUtil.KEY_ROOM_ID;
import static video.pano.audiochat.utils.SPUtil.KEY_USER_NAME;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat.OnRequestPermissionsResultCallback;

import java.util.List;
import java.util.Random;

import pub.devrel.easypermissions.AppSettingsDialog;
import pub.devrel.easypermissions.EasyPermissions;
import video.pano.audiochat.R;
import video.pano.audiochat.rtc.PanoConfig;
import video.pano.audiochat.utils.SPUtil;
import video.pano.audiochat.utils.Utils;
import video.pano.audiochat.view.ClearableEditText;
import video.pano.audiochat.view.CommonTitle;

public class StartChatRoomActivity extends BaseActivity implements OnRequestPermissionsResultCallback, EasyPermissions.PermissionCallbacks {

    private static final int PERMISSION_REQUEST_CODE = 1;
    private static final String TAG_CREATE = "isCreate";
    private boolean mIsCreate;
    private ClearableEditText mRoomIdEdit;
    private ClearableEditText mUserNameEdit;

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

        String userName = (String) SPUtil.getValue(this,KEY_USER_NAME, "");
        String roomId = (String) SPUtil.getValue(this,KEY_ROOM_ID, "");

        if (!TextUtils.isEmpty(userName)) {
            mUserNameEdit.setText(userName);
        }
        if(!TextUtils.isEmpty(roomId)){
            mRoomIdEdit.setText(roomId);
        }

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
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, this);
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

        if(!Utils.doubleClick()){
            checkRtcPermission();
        }
    }

    private void checkRtcPermission() {
        if (EasyPermissions.hasPermissions(Utils.getApp(), PanoConfig.RTC_PERMISSIONS)) {
            startRoom();
        } else {
            EasyPermissions.requestPermissions(this, getString(R.string.pano_title_ask_again),
                    PERMISSION_REQUEST_CODE, PanoConfig.RTC_PERMISSIONS);
        }
    }

    @Override
    public void onPermissionsGranted(int requestCode, @NonNull List<String> perms) {
        if(requestCode != PERMISSION_REQUEST_CODE) return ;
        if(perms.size() == PanoConfig.RTC_PERMISSIONS.length){
            startRoom();
        }
    }

    @Override
    public void onPermissionsDenied(int requestCode, @NonNull List<String> perms) {
        if (EasyPermissions.somePermissionPermanentlyDenied(this, perms)) {
            new AppSettingsDialog.Builder(this).setTitle(R.string.pano_title_ask_again).setRationale(R.string.pano_rationale_ask_again)
                    .build().show();
        } else {
            Toast.makeText(this, R.string.permission_required_title, Toast.LENGTH_SHORT).show();
        }
    }

    private void startRoom(){
        String roomId = mRoomIdEdit.getText().toString();
        String userName = mUserNameEdit.getText().toString();
        long userId = 10000 + new Random().nextInt(5000);
        ChatRoomActivity.start(StartChatRoomActivity.this, roomId, userName, userId, PanoConfig.TOKEN, mIsCreate, PanoConfig.HOST_USER_ID);
    }
}
