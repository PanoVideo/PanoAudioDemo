package video.pano.audiochat.utils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import video.pano.audiochat.PACApplication;

public class AssetUtil {

    private static final String[] BGM_FILE_NAME = {"music1.mp3", "music2.mp3", "music3.mp3"};
    private static final String[] SOUND_FILE_NAME = {"hahaha.caf", "wow.caf", "clap.caf",
            "awkward.caf", "crow.caf", "heckle.caf"};

    public static String[] OUT_BGM_FILE_NAME = new String[BGM_FILE_NAME.length];
    public static String[] OUT_SOUND_FILE_NAME = new String[SOUND_FILE_NAME.length];

    public static void init() {
        ThreadUtils.sSingleThreadExecutor.execute(() -> {
            for (int i = 0; i < BGM_FILE_NAME.length; i++) {
                OUT_BGM_FILE_NAME[i] = copyAssetAndWrite(BGM_FILE_NAME[i]);
            }
            for (int i = 0; i < SOUND_FILE_NAME.length; i++) {
                OUT_SOUND_FILE_NAME[i] = copyAssetAndWrite(SOUND_FILE_NAME[i]);
            }
        });
    }

    private static String copyAssetAndWrite(String fileName) {
        try {
            File cacheDir = PACApplication.getInstance().getCacheDir();
            if (!cacheDir.exists()) {
                cacheDir.mkdirs();
            }
            File outFile = new File(cacheDir, fileName);
            if (!outFile.exists()) {
                boolean res = outFile.createNewFile();
                if (!res) {
                    return "";
                }
            } else {
                if (outFile.length() > 10) {
                    return outFile.getAbsolutePath();
                }
            }
            InputStream is = PACApplication.getInstance().getAssets().open(fileName);
            FileOutputStream fos = new FileOutputStream(outFile);
            byte[] buffer = new byte[1024];
            int byteCount;
            while ((byteCount = is.read(buffer)) != -1) {
                fos.write(buffer, 0, byteCount);
            }
            fos.flush();
            is.close();
            fos.close();
            return outFile.getAbsolutePath();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return "";
    }
}
