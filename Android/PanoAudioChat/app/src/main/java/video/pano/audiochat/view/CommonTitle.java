package video.pano.audiochat.view;

import android.app.Activity;
import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.constraintlayout.widget.ConstraintLayout;

import video.pano.audiochat.R;

public class CommonTitle extends ConstraintLayout {

    private ImageView mBackIv;
    private TextView mTitleTv;

    public CommonTitle(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);

        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.CommonTitle);
        String customTitle = typedArray.getString(R.styleable.CommonTitle_customTitle);
        init(customTitle);

        typedArray.recycle();
    }

    private void init(String customTitle) {
        View rootView = LayoutInflater.from(getContext()).inflate(R.layout.common_title, this, true);
        mBackIv = rootView.findViewById(R.id.title_back_iv);
        mTitleTv = rootView.findViewById(R.id.title_tv);
        mBackIv.setOnClickListener(v -> ((Activity) getContext()).finish());
        mTitleTv.setText(customTitle);
    }

    public void setTitle(@StringRes int resId) {
        mTitleTv.setText(resId);
    }

    public void setTitle(String title) {
        mTitleTv.setText(title);
    }
}
