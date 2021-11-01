package video.pano.audiochat.model;

import java.io.Serializable;

public class Song implements Serializable {
    private static final long serialVersionUID = 7165515912861193602L;

    public String name;
    public String localSongPath;
    public String artist;

    public void setArtist(String artist) {
        this.artist = artist;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setLocalSongPath(String localSongPath) {
        this.localSongPath = localSongPath;
    }

    public String getLocalSongPath() {
        return localSongPath;
    }
}
