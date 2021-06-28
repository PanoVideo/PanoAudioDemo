//
//  PanoClientService+OpenApi.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2021/6/11.
//

import Foundation

extension PanoClientService: PanoSignalInterface {
    
    func joinAudioRoom(config: PanoClientConfig, completion: @escaping (Bool) -> Void) {
        self.config = config;
        self.joinCompletion = completion
        PanoClientService.userName = config.userName
        PanoClientService.roomId = config.roomId
        PanoClientService.userId = config.userId
        PanoClientService.savePreferences()
        fetchTokenWithCompletionHandler { (token, hostUserId , error) in
            guard error == nil ,
                  let token = token,
                  let hostUserId = hostUserId,
                  token.count > 0 else {
                completion(false)
                return
            }
            self.createEngineKit()
             
            let chanelConfig = PanoRtcChannelConfig()
            chanelConfig.mode = .channelMeeting
            chanelConfig.subscribeAudioAll = true
            chanelConfig.userName = config.userName
            let res = self.engineKit?.joinChannel(withToken: token, channelId: config.roomId, userId: config.userId, config: chanelConfig)
            if res == .OK {
                print("joinChannel begin", NSDate())
                PanoClientService.joined = true
                let userService = PanoServiceManager.service(type: .user) as? PanoUserService;
                userService?.onUserJoinIndication(config.userId, withName: config.userName)
                UIApplication.shared.isIdleTimerDisabled = true
                PanoClientService.hostUserId = UInt64(Int(hostUserId)!)
            } else {
                completion(false)
            }
        }
    }
    
    @objc func leaveAudioRoom() {
        if !PanoClientService.joined {
            return
        }
        self.joinCompletion = nil
        PanoClientService.joined = false
        var after = 0.0;
        if config.userMode == .anchor {
            /**
               关闭房间有两种方式，
                第一： 通过发送广播消息，然后大家离开会议
                第二：调用RestfulApi close channel
             */
            _ = self.signalService?.sendCloseRoomMsg()
            
            // self.closeChannelWithHandler()
            after = 1.5;
        }
        self.uploadlogsAutomatically()
        PanoAudioService.service()?.stopAudioDump()
        PanoPlayerService.service()?.unLoadMusicResouces()
        engineKit?.whiteboardEngine().setDelegate(nil)
        PanoServiceManager.uninit()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + after) {
            self.destroyEngineKit()
            UIApplication.shared.isIdleTimerDisabled = false
            
        }
    }
    
    func sendMessage(msg: Dictionary<String, Any>, toUser: UInt64) -> Bool {
        print("rtmState->", rtmState.rawValue);
        let data = try! JSONSerialization.data(withJSONObject: msg, options: JSONSerialization.WritingOptions(rawValue: 0))
        let result = engineKit?.messageService.send(toUser: toUser, data: data)
        print("sendMessage result->", result?.rawValue)
        return result == .OK
    }
    
    func broadcastMessage(msg: Dictionary<String, Any>) -> Bool {
        print("rtmState->", rtmState.rawValue);
        let data = try! JSONSerialization.data(withJSONObject: msg, options: JSONSerialization.WritingOptions(rawValue: 0))
        let result = engineKit?.messageService.broadcast(data, sendBack: true)
        print("broadcastMessage result->", result?.rawValue)
        return result == .OK
    }
    
    func setProperty(value: Any? = nil, for key: String) -> Bool {
        var data: Data = Data();
        if let d = value {
            data = try! JSONSerialization.data(withJSONObject: d, options: JSONSerialization.WritingOptions(rawValue: 0))
        }
        let result = engineKit?.messageService.setProperty(key, value: data)
        return result == .OK
    }
    
    func addDelegate(delegate: PanoClientDelegate) {
        delegates.addDelegate(delegate);
    }
    
    /// 移除回调
    func removeDelegate(delegate: PanoClientDelegate) {
        delegates.removeDelegate(delegate);
    }

}
