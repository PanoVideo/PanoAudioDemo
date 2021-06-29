package video.pano.audiochat.rtc.data;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

import video.pano.audiochat.rtc.PanoTypeConstant;

public class BaseMessage implements Serializable {

    private static final long serialVersionUID = -9072307905973787354L;
    @SerializedName("cmd")
    public int cmd ;

    @SerializedName("version")
    public String version ;

    @SerializedName("timestamp")
    public long timestamp ;

    @SerializedName("reason")
    public int reason ;

    public BaseMessage(int cmd) {
        this.cmd = cmd;
        this.reason = PanoTypeConstant.REASON_NONE;
        this.version = "1";
        this.timestamp = System.currentTimeMillis() ;
    }

    public BaseMessage(int cmd, int reason) {
        this.cmd = cmd;
        this.reason = reason;
        this.version = "1";
        this.timestamp = System.currentTimeMillis() ;
    }

    public int getCmd() {
        return cmd;
    }

    public void setCmd(int cmd) {
        this.cmd = cmd;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }

    public int getReason() {
        return reason;
    }

    public void setReason(int reason) {
        this.reason = reason;
    }
}
