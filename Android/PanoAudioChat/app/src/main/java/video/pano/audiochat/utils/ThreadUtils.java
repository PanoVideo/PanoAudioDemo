package video.pano.audiochat.utils;

import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

public class ThreadUtils {
    public static final Executor sSingleThreadExecutor = Executors.newSingleThreadExecutor();
}
