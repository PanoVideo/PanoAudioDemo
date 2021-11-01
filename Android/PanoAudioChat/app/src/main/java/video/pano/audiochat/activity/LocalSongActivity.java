package video.pano.audiochat.activity;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.io.File;
import java.io.FilenameFilter;
import java.lang.ref.WeakReference;
import java.util.List;

import video.pano.audiochat.R;
import video.pano.audiochat.adapter.LocalSongListAdapter;
import video.pano.audiochat.model.Song;
import video.pano.audiochat.utils.FileUtils;
import video.pano.audiochat.utils.ThreadUtils;

public class LocalSongActivity extends BaseActivity implements LocalSongListAdapter.OnItemClickListener {

    private static final int DISPLAY_MUSIC_FILE_FLAG = 100;
    private static final int NO_SDCARD_FLAG = 200;

    public static final String EXTRA_SONG_DATA = "extra_song_data";

    private View mDefaultView;
    private RecyclerView mLocalSongList;

    private final Handler mSongHandler = new SongHandler(LocalSongActivity.this);
    private LocalSongListAdapter mAdapter;

    static class SongHandler extends Handler {
        WeakReference<LocalSongActivity> songActivityWeakReference;

        SongHandler(LocalSongActivity localSongActivity) {
            songActivityWeakReference = new WeakReference<>(localSongActivity);
        }

        boolean isFinish() {
            return songActivityWeakReference == null || songActivityWeakReference.get() == null || songActivityWeakReference.get().isFinishing();
        }

        @Override
        public void handleMessage(@NonNull Message msg) {
            LocalSongActivity localSongActivity = songActivityWeakReference.get();
            if (isFinish()) {
                return;
            }
            switch (msg.what) {
                case NO_SDCARD_FLAG:
                    localSongActivity.setEmptyView();
                    break;
                case DISPLAY_MUSIC_FILE_FLAG:
                    List<Song> songList = (List<Song>) msg.obj;
                    localSongActivity.setSongListData(songList);
                    break;
                default:
                    localSongActivity.setEmptyView();
                    break;
            }

        }
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_local_song);
        ayncInitData();
        initViews();
    }

    private void initViews() {
        mLocalSongList = findViewById(R.id.rv_local_song);
        mDefaultView = findViewById(R.id.ll_default);

        mAdapter = new LocalSongListAdapter();
        mAdapter.setOnItemClickListener(this);
        mLocalSongList.setLayoutManager(new LinearLayoutManager(getApplicationContext(), LinearLayoutManager.VERTICAL, false));
        mLocalSongList.setAdapter(mAdapter);
    }

    private void setEmptyView() {
        mLocalSongList.setVisibility(View.GONE);
        mDefaultView.setVisibility(View.VISIBLE);
    }

    private void setSongListData(List<Song> songListData) {
        if (songListData == null || songListData.isEmpty()) {
            setEmptyView();
            return;
        }
        mDefaultView.setVisibility(View.GONE);
        mLocalSongList.setVisibility(View.VISIBLE);
        mAdapter.setData(songListData);
    }

    private void ayncInitData() {
        ThreadUtils.sSingleThreadExecutor.execute(this::initData);
    }

    private void initData() {
        if (FileUtils.isSdCardExist()) {
            FilenameFilter filter = (file, s) -> !(s.indexOf(".") == 0);

            File fileDir = FileUtils.getLocalSongDir();
            if (fileDir == null) {
                mSongHandler.sendEmptyMessage(NO_SDCARD_FLAG);
                return;
            }
            String[] files = fileDir.list(filter);
            if (files != null && files.length > 0) {
                List<Song> localAccompanies = FileUtils
                        .buildSongsFromFiles(fileDir.getAbsolutePath(), files);
                Message msg = new Message();
                msg.obj = localAccompanies;
                msg.what = DISPLAY_MUSIC_FILE_FLAG;
                mSongHandler.sendMessage(msg);
            } else {
                mSongHandler.sendEmptyMessage(NO_SDCARD_FLAG);
            }
        } else {
            mSongHandler.sendEmptyMessage(NO_SDCARD_FLAG);
        }
    }

    @Override
    public void onItemClick(View view, int position, Song song) {
        Intent intent = new Intent();
        intent.putExtra(EXTRA_SONG_DATA, song);
        setResult(ChatRoomActivity.LOCAL_SONG_REQUEST_CODE, intent);
        finish();
    }
}
