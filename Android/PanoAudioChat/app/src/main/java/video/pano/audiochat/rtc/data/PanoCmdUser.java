package video.pano.audiochat.rtc.data;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.Objects;

import video.pano.audiochat.rtc.PanoTypeConstant;

public class PanoCmdUser implements Serializable {
    private static final long serialVersionUID = -7644584754242758097L;

    @SerializedName("userId")
    public long userId;

    @SerializedName("order")
    public int order = -1;

    @SerializedName("status")
    public int status = PanoTypeConstant.NONE;

    public PanoCmdUser(int order) {
        this.userId = -1;
        this.order = order;
    }

    public PanoCmdUser(long userId, int order, int status) {
        this.userId = userId;
        this.order = order;
        this.status = status;
    }

    public PanoCmdUser(PanoUser user){
        this.userId = user.userId;
        this.order = user.order;
        this.status = user.status;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        PanoCmdUser panoUser = (PanoCmdUser) o;
        return userId == panoUser.userId;
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId);
    }


    public void recycle() {
        userId = -1;
        status = PanoTypeConstant.NONE;
    }
}
