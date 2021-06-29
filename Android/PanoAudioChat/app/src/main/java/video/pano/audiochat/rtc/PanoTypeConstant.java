package video.pano.audiochat.rtc;

public class PanoTypeConstant {

    // 发送申请上麦的消息
    public static final int ApplyChat = 1;

    // 发送接受上麦的消息
    public static final int AcceptChat = 2;

    // 发送拒绝上麦的消息
    public static final int RejectChat = 3;

    // 发送下麦的消息
    public static final int StopChat = 4;

    // 发送取消上麦的消息
    public static final int CancelChat = 5;

    //发送自己是主播的消息
    public static final int Host = 100;

    //发送踢人的消息/强制下麦
    public static final int KillUser = 101;

    //发送静音的消息
    public static final int MuteUser = 102;

    //发送取消静音的消息
    public static final int UnmuteUser = 103;

    // 发送关闭房间的消息
    public static final int CloseRoom = 104;

    // 发送邀请上麦消息
    public static final int InviteUser = 105;

    //发送自己麦位信息
    public static final int MicInfo = 106;

    // 发送拒绝主播邀请上麦消息
    public static final int RejectInvite = 107;

    // 发送接受主播邀请上麦消息
    public static final int AcceptInvite = 108;

    // 麦位管理
    public static final int AllMic = 110 ;

    // 普通聊天消息
    public static final int NormalChat = 202;

    // 系统聊天消息
    public static final int SystemChat = 203;

    // 上传日志
    public static final int UploadAudioLog = 300;


    // 观众
    public static int AUDIENCE = 0;
    // 主播
    public static int HOST = 1;

    // 麦位无人
    public final static int NONE = 0;

    // 麦位正在申请, 主播正在邀请观众
    public final static int APPLYING = 1;

    // 申请完成，上麦
    public final static int DONE = 2;

    // 申请完成，上麦, 被主播静音
    public final static int MUTE = 3;

    // 麦位被关闭, 暂未使用
    public final static int INVITING = 4;



    public final static int REASON_NONE = 0;

    // 申请上麦消息超时
    public final static int REASON_TIMEOUT = -1;

    // 麦位已经被占用
    public final static int REASON_OCCUPIED = -2;


    public final static String ALL_MIC_KEY = "msg_all_mic_info_key";


    public static final int DEFAULT_MIC_SIZE = 8 ;

}
