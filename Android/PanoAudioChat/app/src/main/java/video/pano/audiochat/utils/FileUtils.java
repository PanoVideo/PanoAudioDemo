package video.pano.audiochat.utils;

import android.database.Cursor;
import android.os.Environment;
import android.provider.MediaStore;
import android.text.TextUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import video.pano.audiochat.PACApplication;
import video.pano.audiochat.R;
import video.pano.audiochat.model.Song;

public class FileUtils {

    private static final String MUSIC_DIR = "Pano/localSong";
    /*
     * SD是否存在
     * */
    public static boolean isSdCardExist() {
        return android.os.Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState());
    }

    public static List<Song> buildSongsFromFiles(String dirPath , String[] files) {
        List<Song> result = new ArrayList<Song>();
        List<Song> queryResList = queryContentProvider();
        String localPath = null ;
        Song song = null ;
        if(files!=null){
            for(String filename:files){
                if(!filename.toLowerCase().endsWith("mp3")){
                    continue;
                }
                localPath = dirPath +"/"+ filename ;
                song = buildSongFromContentProvider(localPath,queryResList);
                if(song == null){
                    song = buildSongFromMp3File(localPath);
                }
                if(song!=null){
                    result.add(song);
                }
            }
        }
        return result;
    }

    public static Song buildSongFromMp3File(String filePath){
        if(TextUtils.isEmpty(filePath)){
            return null ;
        }
        int titleStart = filePath.lastIndexOf("/");
        int titleEnd = filePath.lastIndexOf(".");
        if(titleStart > 0 &&titleEnd> 0 && titleStart < titleEnd &&  titleEnd < filePath.length() ){
            String filename = filePath.substring(titleStart+1,titleEnd);
            return buildSong(Utils.getApp().getApplicationContext().getString(R.string.title_member_unknown),
                    filename,filePath);
        }
        return null;
    }


    public static Song buildSongFromContentProvider(String localPath,List<Song> list ){
        if(list == null || list.isEmpty()){
            return null ;
        }
        for(Song song:list){
            if(localPath.equals(song.getLocalSongPath())){
                return song;
            }
        }
        return null;
    }

    public static Song buildSong(String artist,String filename,String filePath){
        Song song = new Song();
        song.setArtist(artist);
        song.setName(filename);
        song.setLocalSongPath(filePath);
        return song;
    }

    public static List<Song> queryContentProvider(){
        List<Song> result = new ArrayList<Song>();

        String[] columns = new String[] { MediaStore.Audio.Media.TITLE,
                MediaStore.Audio.Media.DATA, MediaStore.Audio.Media.ARTIST };
        String selection = MediaStore.Audio.Media.DATA + " like ?";
        String[] selectionArgs = new String[] { getLocalSongDir().getAbsolutePath()+ "%" };
        Cursor cursor = null;
        try{
            cursor = Utils.getApp().getApplicationContext().getContentResolver()
                    .query(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, columns,
                            selection, selectionArgs,
                            MediaStore.Audio.Media.DATE_MODIFIED );
            if (cursor != null) {
                while (cursor.moveToNext()) {
                    String filePath = cursor.getString(1);
                    if(TextUtils.isEmpty(filePath)){
                        continue;
                    }
                    if(!filePath.endsWith("mp3")){
                        continue;
                    }
                    File file = new File(filePath);
                    if(!file.exists()){
                        continue;
                    }
                    String filename = cursor.getString(0);
                    String artist = cursor.getString(2);

                    if(null != artist && artist.contains("unknown")){
                        artist = Utils.getApp().getApplicationContext().getString(R.string.title_member_unknown);
                    }
                    Song song= buildSong(artist,filename,filePath);
                    result.add(song);
                }
            }
        }catch (Exception e) {
            e.printStackTrace();
        }finally{
            if(cursor != null){
                cursor.close();
            }
        }
        return result;
    }

    /**
     * 本地伴奏的根目录
     *
     * @return 本地伴奏的根目录
     */
    public static File getLocalSongDir() {
        File sdDir = getSDPath();
        if (sdDir != null && sdDir.isDirectory()) {
            File ktv = new File(sdDir, MUSIC_DIR);
            if (!ktv.exists()) ktv.mkdirs();
            return ktv;
        }
        return null;
    }

    /**
     * 获取sd卡路径
     *
     * @return sd卡绝对路径
     */
    public static File getSDPath() {
        File sdDir = null;
        try {
            sdDir = Environment.getExternalStorageDirectory();// 获取跟目录
        } catch (NullPointerException e) {
            sdDir = new File("/mnt/sdcard"); //4.0
            if (!sdDir.exists()) {
                sdDir = new File("/storage/emulated/0"); //4.2
            }
            if (!sdDir.exists()) {
                sdDir = new File("/storage/sdcard0"); //4.1
            }
        }
        return sdDir;
    }
}
