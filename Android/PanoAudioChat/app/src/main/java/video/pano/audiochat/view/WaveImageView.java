package video.pano.audiochat.view;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import video.pano.audiochat.R;

public class WaveImageView extends androidx.appcompat.widget.AppCompatImageView {

    // 一个波纹从创建到消失的持续时间
    private static final float DURATION = 3000f;
    // 波纹的创建速度，每1000ms创建一个
    private int SPEED = 1000;

    private Paint mPaint = new Paint();
    private int mInitRadius;
    private int mPadding;
    private boolean mRunning = false;
    private long mLastCreateTime;
    private List<Circle> mCircleList = new ArrayList<>();

    private Runnable mCreateCircle = new Runnable() {
        @Override
        public void run() {
            if (mRunning) {
                createCircle();
                postDelayed(mCreateCircle, SPEED);
            }
        }
    };

    public WaveImageView(@NonNull Context context) {
        this(context, null);
    }

    public WaveImageView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);

        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.WaveImageView);
        mPadding = typedArray.getDimensionPixelOffset(R.styleable.WaveImageView_drawablePadding, 0);
        typedArray.recycle();
        setPadding(mPadding, mPadding, mPadding, mPadding);
        post(() -> mInitRadius = getWidth() / 2 - mPadding);
        init();
    }

    private void init() {
        mPaint.setFlags(Paint.ANTI_ALIAS_FLAG);
        mPaint.setStyle(Paint.Style.STROKE);
        mPaint.setDither(true);
        mPaint.setStrokeWidth(3);
        mPaint.setColor(Color.parseColor("#69B4F9"));
    }

    private void createCircle() {
        long currentTime = System.currentTimeMillis();
        if (currentTime - mLastCreateTime < SPEED) {
            return;
        }
        Circle circle = new Circle(mInitRadius, getWidth() / 2);
        mCircleList.add(circle);
        invalidate();
        mLastCreateTime = currentTime;
    }

    public void startWave() {
        if (!mRunning) {
            mRunning = true;
            mCreateCircle.run();
        }
    }

    public void stopWave() {
        mRunning = false;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        float centerX = getWidth() / 2f;
        float centerY = getHeight() / 2f;

        Iterator<Circle> iterator = mCircleList.iterator();
        while (iterator.hasNext()) {
            Circle circle = iterator.next();
            if (System.currentTimeMillis() - circle.mCreateTime < DURATION) {
                mPaint.setAlpha(circle.getAlpha());
                canvas.drawCircle(centerX, centerY, circle.getCurrentRadius(), mPaint);
            } else {
                iterator.remove();
            }
        }
        if (mCircleList.size() > 0) {
            postInvalidateDelayed(10);
        }

    }

    private static class Circle {
        private long mCreateTime;

        // 初始波纹半径
        private float mInitialRadius;
        // 最大波纹半径
        private float mMaxRadius;

        public Circle(int initRadius, int maxRadius) {
            this.mCreateTime = System.currentTimeMillis();
            mInitialRadius = initRadius;
            mMaxRadius = maxRadius;
        }

        public int getAlpha() {
            float percent = (System.currentTimeMillis() - mCreateTime) / DURATION;
            return (int) ((1.0f - percent) * 255);
        }

        public float getCurrentRadius() {
            float percent = (System.currentTimeMillis() - mCreateTime) / DURATION;
            return mInitialRadius + percent * (mMaxRadius - mInitialRadius);
        }
    }
}
