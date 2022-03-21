package video.pano.audiochat.rtc;


import static android.Manifest.permission.READ_EXTERNAL_STORAGE;
import static android.Manifest.permission.RECORD_AUDIO;
import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;

public class PanoConfig {

    /**
     * SDK 到 Pano Cloud 的所有交互都需要使用 Token，Token的生成方式有两种。
     * 第一种是 App Server 通过 RESTful API 向 Pano 服务器获取。
     * 第二种是 App Server 按照 Pano 定义的规则本地生成
     * 请参考 https://developer.pano.video/restful/authtoken/
     * <p>
     * 第三种 调试阶段 可以临时 Token, 可以在控制台创建应用
     * 请参考 https://console.pano.video/#/user/login
     * <p>
     * 加入房间后需要获取到 "Token" 和  "主播的 UserId"，需要 客户的App Server 提供接口
     * <p>
     * 创建语聊房  调试可以返回 "临时Token"  和 "当前用户的Userid"
     * 加入语聊房  调试可以返回 "临时Token"  和 "主播UserId"
     * <p>
     * 客户的App Server 需要保证
     * 1. 同一个房间ID，同一时间 只能有一个主播加入
     */
    public static final String APPID = Your AppId;
    public static final String TOKEN = Your Token;
    public static final String PRODUCT_NAME = Your App Name;
    public static final String PANO_SERVER = "api.pano.video";
    public static final String HOST_USER_ID = Your Host UserId;


    public static final String[] RTC_PERMISSIONS = {
            RECORD_AUDIO,
            READ_EXTERNAL_STORAGE,
            WRITE_EXTERNAL_STORAGE,
    };

}


