package video.pano.audiochat.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import video.pano.audiochat.R;
import video.pano.audiochat.rtc.data.PanoCmdUser;

public class WaitingView extends FrameLayout {

    private WaitingCallback mWaitingCallback ;
    private PanoCmdUser mUser;

    public WaitingView(@NonNull Context context) {
        this(context, null);
    }

    public WaitingView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);

        View rootView = LayoutInflater.from(getContext()).inflate(
                R.layout.room_applying_waiting_pop, this, true);

        TextView cancel = rootView.findViewById(R.id.cancel);
        cancel.setOnClickListener(v -> {
            if(mWaitingCallback != null){
                mWaitingCallback.onClickCancel(mUser);
            }
        });
    }

    public void setCmdUser(PanoCmdUser user) {
        mUser = user;
    }

    public void setWaitingCallback(WaitingCallback callback) {
        mWaitingCallback = callback;
    }

    public interface WaitingCallback {
        void onClickCancel(PanoCmdUser user);
    }
}
