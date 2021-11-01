package video.pano.audiochat.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;

import video.pano.audiochat.R;
import video.pano.audiochat.model.Song;

public class LocalSongListAdapter extends RecyclerView.Adapter<LocalSongListAdapter.Holder> {

    private List<Song> mItems = new ArrayList<>();

    @NonNull
    @Override
    public Holder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.layout_local_song_item,parent,false);
        return new LocalSongListAdapter.Holder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull Holder holder, int position) {
        Song song = getItem(position);
        if(song == null) return ;
        holder.itemView.setOnClickListener(v -> {
            if (mOnItemClickListener != null) {
                mOnItemClickListener.onItemClick(v, position,song);
            }
        });
        holder.singerNameText.setText(song.artist);
        holder.songNameText.setText(song.name);
    }

    public Song getItem(int i) {
        if (i > -1 && i < getItemCount()) {
            return mItems.get(i);
        }
        return null;
    }

    @Override
    public int getItemCount() {
        if (mItems != null) {
            return (mItems.size());
        }
        return 0;
    }

    public void setData(List<Song> items){
        if (mItems == null) {
            mItems = new ArrayList<>();
        }
        if (items != null) {
            mItems.clear();
            mItems.addAll(items);
        }else{
            mItems.clear();
        }
        notifyDataSetChanged();
    }

    public static class Holder extends RecyclerView.ViewHolder {

        public TextView songNameText;
        public TextView singerNameText;

        public Holder(@NonNull View itemView) {
            super(itemView);
            songNameText = itemView.findViewById(R.id.tv_song_name);
            singerNameText = itemView.findViewById(R.id.tv_singer_name);
        }
    }


    private OnItemClickListener mOnItemClickListener;
    public void setOnItemClickListener(OnItemClickListener onItemClickListener){
        mOnItemClickListener = onItemClickListener;
    }

    public interface OnItemClickListener {
        void onItemClick(View view, int position, Song song);
    }
}
