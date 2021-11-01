package video.pano.audiochat.rtc.data;

import com.google.gson.annotations.SerializedName;

import java.util.Objects;

import video.pano.audiochat.rtc.PanoTypeConstant;

public class PanoUser {

    @SerializedName("userId")
    public long userId;

    @SerializedName("userName")
    public String userName;

    @SerializedName("order")
    public int order = -1;

    @SerializedName("status")
    public int status = PanoTypeConstant.NONE;

    @SerializedName("audioStatus")
    public int audioStatus = PanoTypeConstant.MIC_UN_MUTE;

    @SerializedName("isHost")
    public boolean isHost = false;

    @SerializedName("speaking")
    public boolean speaking = false;

    public PanoUser(long userId, String userName) {
        this.userId = userId;
        this.userName = userName;
    }

    public PanoUser(int order) {
        this.userId = -1;
        this.userName = null;
        this.order = order;
    }

    public PanoUser(PanoCmdUser cmdUser) {
        this.userId = cmdUser.userId;
        this.order = cmdUser.order;
        this.status = cmdUser.status;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        PanoUser panoUser = (PanoUser) o;
        return userId == panoUser.userId;
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId);
    }

    public void recycle() {
        userId = -1;
        userName = null;
        //micOrder = -1;
        status = PanoTypeConstant.NONE;
        audioStatus = PanoTypeConstant.MIC_UN_MUTE;
        isHost = false;
        speaking = false;
    }
}
