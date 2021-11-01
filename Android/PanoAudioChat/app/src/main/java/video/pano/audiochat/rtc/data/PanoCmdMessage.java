package video.pano.audiochat.rtc.data;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class PanoCmdMessage extends BaseCmdMessage implements Serializable {
    private static final long serialVersionUID = -6964392804540462611L;

    @SerializedName("data")
    public List<PanoCmdUser> data = new ArrayList<>();

    public PanoCmdMessage(int cmd, PanoCmdUser user) {
        super(cmd);
        addData(user);
    }

    public PanoCmdMessage(int cmd, int reason , PanoCmdUser user) {
        super(cmd,reason);
        addData(user);
    }

    public PanoCmdMessage(int cmd, List<PanoCmdUser> datas) {
        super(cmd);
        addData(datas);
    }

    private void addData(PanoCmdUser user) {
        data.clear();
        data.add(user);
    }

    private void addData(List<PanoCmdUser> datas) {
        data.clear();
        data.addAll(datas);
    }

    public void setData(List<PanoCmdUser> data) {
        this.data = data;
    }

    public List<PanoCmdUser> getData() {
        return data;
    }
}
