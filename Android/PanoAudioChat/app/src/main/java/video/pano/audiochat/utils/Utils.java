package video.pano.audiochat.utils;

public class Utils {

    private static long lastClickTime = 0;

    public synchronized static boolean doubleClick() {
        long time = System.currentTimeMillis();
        long value = time - lastClickTime;
        if (Math.abs(value) < 1000) {
            return true;
        }
        lastClickTime = time;
        return false;
    }
}
