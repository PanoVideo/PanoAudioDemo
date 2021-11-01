package video.pano.audiochat.rtc.data;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

public class PanoNormalMessage extends BaseCmdMessage implements Serializable {

    private static final long serialVersionUID = 6481119346600619512L;

    @SerializedName("data")
    public NormalData data ;

    public PanoNormalMessage(int cmd, String content, long userId) {
        super(cmd);
        data = new NormalData(content, userId);
    }

    public PanoNormalMessage(int cmd){
        super(cmd);
    }

    public String getContent() {
        return data != null ? data.getContent() : "";
    }

    public long getUserId() {
        return  data != null ? data.getUserId():0L;
    }

    public static class NormalData {
        @SerializedName("msg_chat_content")
        public String content;

        @SerializedName("msg_user_id")
        public long userId;

        public NormalData(String content, long userId) {
            this.content = content;
            this.userId = userId;
        }

        public String getContent() {
            return content;
        }

        public long getUserId() {
            return userId;
        }
    }
}
