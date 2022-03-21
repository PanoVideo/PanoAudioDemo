package video.pano.audiochat.utils;

import android.os.Handler;
import android.os.Looper;

import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

public class ThreadUtils {
    public static final Executor sSingleThreadExecutor = Executors.newSingleThreadExecutor();
    private static final Object sLock = new Object();
    private static Handler sUiThreadHandler;

    private static Handler getUiThreadHandler() {
        synchronized (sLock) {
            if (sUiThreadHandler == null) {
                sUiThreadHandler = new Handler(Looper.getMainLooper());
            }
            return sUiThreadHandler;
        }
    }

    public static void runOnUiThread(Runnable r) {
        if (!runningOnUiThread()) {
            getUiThreadHandler().post(r);
        } else {
            r.run();
        }
    }

    public static boolean runningOnUiThread() {
        return Looper.myLooper() == Looper.getMainLooper();
    }
}
