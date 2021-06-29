package video.pano.audiochat.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;

import java.util.List;

import video.pano.audiochat.R;
import video.pano.audiochat.adapter.MicApplyAdapter;
import video.pano.audiochat.rtc.PanoUserMgr;
import video.pano.audiochat.rtc.data.PanoCmdUser;
import video.pano.audiochat.rtc.data.PanoUser;

public class MicApplyView extends ConstraintLayout {

    private ListView mApplyList;
    private TextView mBadgeNum;
    private MicApplyAdapter mMicApplyAdapter;

    public MicApplyView(@NonNull Context context) {
        this(context, null);
    }

    public MicApplyView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);

        View rootView = LayoutInflater.from(getContext()).inflate(
                R.layout.room_mic_apply_popup_layout, this, true);
        mApplyList = rootView.findViewById(R.id.apply_list);
        mBadgeNum = rootView.findViewById(R.id.apply_num);

        mMicApplyAdapter = new MicApplyAdapter(getContext());
        mApplyList.setAdapter(mMicApplyAdapter);
        refresh();
    }

    public void setDealApplyCallback(MicApplyAdapter.DealApplyCallback callback) {
        mMicApplyAdapter.setDealApplyCallback(callback);
    }

    public void refresh() {
        List<PanoCmdUser> userList = PanoUserMgr.getIns().getMicApplyList();

        mMicApplyAdapter.setDataList(userList);
        mMicApplyAdapter.notifyDataSetChanged();

        if (userList.size() > 0) {
            setListViewHeight();
        }
        mBadgeNum.setText(String.valueOf(userList.size()));
    }

    private void setListViewHeight() {
        View itemView = mMicApplyAdapter.getView(0, null, mApplyList);
        itemView.measure(0,0);
        int itemHeight = itemView.getMeasuredHeight();
        int itemCount = mMicApplyAdapter.getCount();
        ViewGroup.LayoutParams layoutParams = mApplyList.getLayoutParams();
        if (itemCount > 4) {
            layoutParams.height = itemHeight * 4 + itemHeight / 2;
        } else {
            layoutParams.height = itemHeight * itemCount;
        }
        mApplyList.setLayoutParams(layoutParams);
    }
}
