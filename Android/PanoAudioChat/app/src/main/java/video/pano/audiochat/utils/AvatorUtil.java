package video.pano.audiochat.utils;

import android.util.LongSparseArray;

import video.pano.audiochat.R;

public class AvatorUtil {

    private static final int[] AVATOR_RES = new int[]{R.drawable.avator00, R.drawable.avator01,
            R.drawable.avator02, R.drawable.avator03, R.drawable.avator04, R.drawable.avator05,
            R.drawable.avator06, R.drawable.avator07, R.drawable.avator08, R.drawable.avator09,
            R.drawable.avator10, R.drawable.avator11, R.drawable.avator12, R.drawable.avator13,
            R.drawable.avator14, R.drawable.avator15,  R.drawable.avator16, R.drawable.avator17,
            R.drawable.avator18, R.drawable.avator19, R.drawable.avator20, R.drawable.avator21};

    private static final boolean[] AVATORS_USED = new boolean[AVATOR_RES.length];
    private static final LongSparseArray<Integer> sCache = new LongSparseArray<>();

    public static int getAvatorResByUserId(long userId) {

        Integer resId = sCache.get(userId);
        if (resId != null && resId != 0) {
            return resId;
        }

        int hash = (int)(userId % AVATOR_RES.length);
        if (!AVATORS_USED[hash]) {
            AVATORS_USED[hash] = true;
            sCache.put(userId, AVATOR_RES[hash]);
            return AVATOR_RES[hash];
        }

        for (int i = 0; i < AVATORS_USED.length; i++) {
            if (!AVATORS_USED[i]) {
                AVATORS_USED[hash] = true;
                sCache.put(userId, AVATOR_RES[i]);
                return AVATOR_RES[i];
            }
        }

        sCache.put(userId, AVATOR_RES[hash]);
        return AVATOR_RES[hash];
    }
}
