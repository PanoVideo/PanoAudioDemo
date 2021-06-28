//
//  PanoMessageDefine.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import Foundation

// MARK: RTM MESSAGE KEY
let PanoAudioChatMsg = "pano_audio_chat"

let PanoMsgUserId = "msg_user_id"

let PanoMsgChatContent = "msg_chat_content"

// 申请上麦或者邀请上麦消息的超时时间
let PanoMsgExpireInterval: UInt64 = 30

// MARK: key: PropertyKey, value: [String : Any]
let PanoAllMicKey = "msg_all_mic_info_key"

/// 消息类型
public enum PanoMsgType : UInt64 {
    
    case none = 0
    
    case applyChat = 1    // 观众发送申请上麦的消息
    
    case acceptChat = 2   // 主播发送给申请人接受上麦的消息
    
    case rejectChat = 3   // 主播发送给申请人拒绝上麦的消息
    
    case stopChat = 4   // 观众发送下麦的消息
    
    case cancelChat = 5  // 观众发送取消上麦的消息
    
    case killUser = 101  //主播发送踢人的消息
    
    case closeRoom = 104 // 发送关闭房间的消息
    
    case inviteUser = 105 // 发送邀请上麦消息
    
    case rejectInvite = 107 // 发送拒绝主播邀请上麦消息

    case acceptInvite = 108 // 发送接受主播邀请上麦消息
    
    case allMic = 110      // 更新麦位信息
    
    case normalChat = 202 // 普通聊天消息
    
    case systemChat = 203 // 系统聊天消息
    
    case uploadAudioLog = 300 // 上传日志
}

/// 麦位状态
public enum PanoMicStatus: Int {
    
    case none = 0         // 麦位无人
    
    case connecting = 1   // 麦位正在申请, 主播正在邀请观众
    
    case finished = 2     // 申请完成，上麦
    
    case finishedMuted = 3 // 申请完成，上麦, 被主播静音
    
    case closed = 4       // 麦位被关闭, 暂未使用
    
}

/// 原因列表
public enum PanoCmdReason: Int {
    case ok = 0
    case timeout = -1    // 申请上麦消息超时
    case occupied = -2   // 麦位已经被占用
}


public class PanoAbstractMessage {
    var cmd: PanoMsgType = .none    // 消息类型
    var version: String = "1"
    var timestamp: UInt64 = 0       // UTC 秒
    var data: Any? = nil;
    init(cmd: PanoMsgType,
         version: String = "1",
         timestamp: UInt64 = 0,
         data: Any? = nil) {
        self.cmd = cmd
        self.version = version
        self.timestamp = UInt64(Date().timeIntervalSince1970 * 1000)
        self.data = data
    }
    
    init?(dict: [String: Any]) {
        let cmd = dict["cmd"]
        guard cmd is PanoMsgType.RawValue else {
            return nil
        }
        guard let ver = dict["version"] as? String,
              let ts = dict["timestamp"] as? UInt64  else {
            return nil
        }
        self.cmd = PanoMsgType(rawValue: cmd as! UInt64)!
        self.version = ver
        self.timestamp = ts
        if let arr = dict["data"] {
            self.data = arr;
        }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "cmd" : self.cmd.rawValue,
            "version" : self.version,
            "timestamp" : self.timestamp
        ]
    }
}

/**
 * 麦位消息
 * 结构：
 *   ```
 *    {
         cmd = 107;
         data =  (
                     {
                 order = 0;
                 status = 0;
                 userId = 11152258;
             }
         );
         reason = 0;
         timestamp = 1623909591;
         version = 1;
     }
 *   ```
 */
public class PanoMicMessage: PanoAbstractMessage {
    
    // 所有的麦位
    var reason: PanoCmdReason = .ok
    
    init(cmd: PanoMsgType,
         data: [PanoMicInfo] = [],
         reason: PanoCmdReason = .ok) {
        super.init(cmd: cmd, data: data)
        self.reason = reason
    }
    
    /// 解析收到麦位消息 PanoCmdMessage  Dictionary -> Model
    override init?(dict: [String: Any]) {
        guard let reason = dict["reason"] as? Int,
              let arr = dict["data"] as? [[String: Any]] else {
            return nil
        }
        super.init(dict: dict);
        var tempData = [PanoMicInfo]()
        for item in arr {
            if var info = PanoMicInfo(dict: item) {
                info.timestamp = self.timestamp
                tempData.append(info)
            }
        }
        self.data = tempData
        self.reason = PanoCmdReason(rawValue: reason) ?? .ok
    }
    
    /// PanoCmdMessage Model -> Dictionary
    override func toDictionary() -> [String: Any] {
        var info = super.toDictionary();
        let data = (self.data as! [PanoMicInfo]).map({ (mic) -> [String: Any] in
            mic.toDictionary()
        })
        let newInfo: [String : Any] = [
            "data": data,
            "reason": self.reason.rawValue
        ]
        info = info.merging(newInfo) { (cur, b) -> Any in cur }
        print("info", info);
        return info
    }
}

/**
 其它信令消息（聊天）
 */
public class PanoCmdMessage: PanoAbstractMessage {
    
    init(cmd: PanoMsgType,
         data: [String: Any]? = nil) {
        super.init(cmd: cmd, data: data)
    }
    
    override init?(dict: [String : Any]) {
        super.init(dict: dict)
    }
    
    override func toDictionary() -> [String : Any] {
        var info = super.toDictionary();
        if self.data != nil {
            info = info.merging(["data": self.data!]) { (cur, _) -> Any in cur }
        }
        return info
    }
}
