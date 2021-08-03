//
//  PanoMessageEnum.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/16.
//


// MARK: RTM MESSAGE KEY
extern NSString *PanoAudioChatMsg;

extern NSString *PanoMsgUserId;

extern NSString *PanoMsgChatContent;

// 申请上麦或者邀请上麦消息的超时时间
extern UInt64 PanoMsgExpireInterval;

// MARK: key: PropertyKey, value: [String : Any]
extern NSString *PanoAllMicKey;

/// 消息类型
typedef NS_ENUM(NSInteger, PanoMsgType) {
    PanoMsgNone = 0,
    
    applyChat = 1,    // 观众发送申请上麦的消息

    acceptChat = 2,   // 主播发送给申请人接受上麦的消息

    rejectChat = 3,   // 主播发送给申请人拒绝上麦的消息

    stopChat = 4,   // 观众发送下麦的消息

    cancelChat = 5,  // 观众发送取消上麦的消息

    killUser = 101,  //主播发送踢人的消息

    closeRoom = 104, // 发送关闭房间的消息

    inviteUser = 105, // 发送邀请上麦消息

    rejectInvite = 107, // 发送拒绝主播邀请上麦消息

    acceptInvite = 108, // 发送接受主播邀请上麦消息

    allMic = 110,      // 更新麦位信息

    normalChat = 202, // 普通聊天消息

    systemChat = 203, // 系统聊天消息

    uploadAudioLog = 300, // 上传日志
};



/// 麦位状态
typedef NS_ENUM(NSInteger, PanoMicStatus) {
    
    PanoMicNone = 0,         // 麦位无人
    
    PanoMicConnecting = 1,   // 麦位正在申请, 主播正在邀请观众
    
    PanoMicFinished = 2,     // 申请完成，上麦
    
    PanoMicFinishedMuted = 3, // 申请完成，上麦, 被主播静音
    
    PanoMicClosed = 4       // 麦位被关闭, 暂未使用
    
};

/// 原因列表
typedef NS_ENUM(NSInteger, PanoCmdReason) {
    ok = 0,
    timeout = -1,  // 申请上麦消息超时
    occupied = -2   // 麦位已经被占用
};
