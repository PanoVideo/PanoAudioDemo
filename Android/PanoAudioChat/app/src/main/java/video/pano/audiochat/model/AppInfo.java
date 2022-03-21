package video.pano.audiochat.model;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

public class AppInfo implements Serializable {

    private static final long serialVersionUID = 7319118466486560379L;

    @SerializedName("update")
    private int update;
    @SerializedName("version")
    private String version;
    @SerializedName("url")
    private String url;

    public int getUpdate() {
        return update;
    }

    public String getVersion() {
        return version;
    }

    public String getUrl() {
        return url;
    }
}
