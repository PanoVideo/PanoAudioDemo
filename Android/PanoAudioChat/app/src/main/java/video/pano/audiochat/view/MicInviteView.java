package video.pano.audiochat.view;

import android.content.Context;
import android.util.AttributeSet;
import android.util.LongSparseArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.ArrayList;
import java.util.List;

import video.pano.audiochat.R;
import video.pano.audiochat.adapter.MicInviteAdapter;
import video.pano.audiochat.rtc.PanoTypeConstant;
import video.pano.audiochat.rtc.PanoUserMgr;
import video.pano.audiochat.rtc.data.PanoCmdUser;
import video.pano.audiochat.rtc.data.PanoUser;

public class MicInviteView extends LinearLayout implements MicInviteAdapter.MicInviteChooseCallback {

    private TextView mTitle;
    private ListView mInviteList;
    private ImageView mTitleBackIv;
    private MicInviteAdapter mMicInviteAdapter;
    private MicInviteCallback mMicInviteCallback;
    private int mMicOrder;

    public MicInviteView(@NonNull Context context) {
        this(context, null);
    }

    public MicInviteView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);

        View rootView = LayoutInflater.from(getContext()).inflate(
                R.layout.room_mic_invite_popup_layout, this, true);

        mTitle = findViewById(R.id.title);
        mTitleBackIv = findViewById(R.id.title_back_iv);
        mTitleBackIv.setOnClickListener(v -> {
            if (mMicInviteCallback != null) {
                mMicInviteCallback.onClickBack();
            }
        });
        mInviteList = rootView.findViewById(R.id.invite_list);
        ViewGroup.LayoutParams params = mInviteList.getLayoutParams();
        params.height = context.getResources().getDisplayMetrics().heightPixels * 4 / 5;
        mInviteList.setLayoutParams(params);

        mMicInviteAdapter = new MicInviteAdapter(getContext());
        mMicInviteAdapter.setMicInviteChooseCallback(this);
        mInviteList.setAdapter(mMicInviteAdapter);
        refreshUI();
    }

    public void setMicOrder(int order) {
        mMicOrder = order;
    }

    public void refreshUI() {
        LongSparseArray<PanoUser> userList = PanoUserMgr.getIns().getUserList();
        List<PanoUser> tempList = new ArrayList<>();
        int size = userList.size();
        for(int i = 0 ; i < size ; i ++){
            PanoUser user = userList.valueAt(i);
            if (user.status == PanoTypeConstant.NONE && !user.isHost) {
                tempList.add(user);
            }
        }
        mMicInviteAdapter.setData(tempList);
        mTitle.setText(getContext().getString(R.string.room_invite_member_title)
                + "(" + tempList.size() + ")");
        mMicInviteAdapter.notifyDataSetChanged();
        mInviteList.requestLayout();
    }

    public void setMicInviteCallback(MicInviteCallback callback) {
        mMicInviteCallback = callback;
    }

    @Override
    public void onInviteUser(PanoUser user) {
        if (mMicInviteCallback != null) {
            mMicInviteCallback.onInviteUser(mMicOrder, user);
        }
    }

    public interface MicInviteCallback {
        void onClickBack();
        void onInviteUser(int micOrder, PanoUser user);
    }

}
