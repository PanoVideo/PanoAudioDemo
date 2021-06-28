//
//  PanoClientService.swift
//  PanoAudioRoom
//
//  Created by wenhua.zhang on 2020/10/28.
//

import Foundation

class PanoClientService : PanoBaseService,
                          PanoRtcEngineDelegate,
                          PanoRtcWhiteboardDelegate,
                          PanoRtcMessageDelegate {
    
    var config: PanoClientConfig!;
    
    var userId : UInt64 {
        return config.userId
    }
    
    var engineKit: PanoRtcEngineKit?
    
    var delegates = MulticastDelegate<PanoClientDelegate>();
    
    var joinCompletion: ((Bool) -> Void)? = nil
    
    @objc static var joined = false
    
    var uploadlogType: PanoMsgType?
    
    var uploadlogMessage: String?
    
    // rmts 连接状态
    var rtmState: PanoMessageServiceState = .unavailable;
    
    // 主持人的用户ID
    static var hostUserId: UInt64 = 0
    
    var signalService: PanoSignalService?;
    
    // MARK: Private Interface
    override class func service() -> PanoClientService {
        return  PanoServiceManager.service(type: .client) as! PanoClientService
    }
    
    override func uninit() {
        self.delegates.removeAllDelegates()
    }
    
    class func rtcEngineKit() -> PanoRtcEngineKit? {
        let clientService = PanoServiceManager.service(type: .client) as! PanoClientService
        return clientService.engineKit
    }
    
    func createEngineKit() {
        destroyEngineKit()
        PanoRtcEngineKit.setLogLevel(.info)
        let engineConfig = PanoRtcEngineConfig()
        engineConfig.appId = AppConfig.PanoAppID
        engineConfig.rtcServer = AppConfig.PanoRtcServerURL
        engineConfig.audioAecType = PanoClientService.audioAdvanceProcess ? .aecDefault : .aecDisable
        engineKit = PanoRtcEngineKit.engine(with: engineConfig, delegate: self)
        engineKit?.whiteboardEngine().setDelegate(self)
        setupAudioConfig(flag: PanoClientService.audioAdvanceProcess)
        engineKit?.messageService.delegate = self
        
        signalService = PanoSignalService();
    }
    
    func destroyEngineKit() {
        engineKit?.messageService.delegate = nil;
        engineKit?.whiteboardEngine().close()
        engineKit?.leaveChannel()
        engineKit?.destroy()
        engineKit = nil
        
        signalService = nil;
    }
    
    func setupAudioConfig(flag: Bool = true) {
        var v =
            flag ? PanoAudioPreProcessModeOption.preProcessDefault.rawValue as NSObject :
                    PanoAudioPreProcessModeOption.preProcessDisable.rawValue as NSObject
        engineKit?.setOption(v, for: .audioPreProcessMode)
        
        v = flag ? PanoAudioNoiseSuppressionLevelOption.nsLvlDefault.rawValue as NSObject :
                    PanoAudioNoiseSuppressionLevelOption.nsLvlDisable.rawValue as NSObject
        engineKit?.setOption(v, for: .audioNoiseSuppressionLevel)
        
        v = flag ? PanoAudioAutoGainControlOption.agcDefault.rawValue as NSObject :
                    PanoAudioAutoGainControlOption.agcDisable.rawValue as NSObject
        engineKit?.setOption(v, for: .audioAutoGainControl)
    }
    
    func initAudioChanger() {
        PanoClientService.setAudioVoiceChangerMode(mode: PanoClientService.audioVoiceChanger)
    }
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(leaveAudioRoom), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    // MARK: PanoRtcMessageDelegate
    func onServiceStateChanged(_ state: PanoMessageServiceState, reason: PanoResult) {
        print("state", state.rawValue, ",reason", reason.rawValue)
        DispatchQueue.main.async {
            self.rtmState = state
            self.delegates.invokeDelegates { (del) in
                del.onRtmStateChanged(state == .available)
            }
        }
    }
    
    func onPropertyChanged(_ props: [PanoPropertyAction]) {
        DispatchQueue.main.async {
            for prop in props {
                self.delegates.invokeDelegates { (del) in
                    if let data = prop.propValue,
                       let v = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any] {
                        del.onPropertyChanged(v , for: prop.propName)
                    }
                }
            }
        }
    }
    
    func onUserMessage(_ userId: UInt64, data: Data) {
        DispatchQueue.main.async {
            let message = data
            guard message.count > 0 else { return }
            let res = try! JSONSerialization.jsonObject(with: message, options: JSONSerialization.ReadingOptions(rawValue: 0))
            if res is [String : Any] {
                self.delegates.invokeDelegates { (del) in
                    del.onMessageReceived(res as! [String : Any], fromUser: userId)
                }
                // 开启音频dump
                guard let cmd = PanoCmdMessage(dict: res as! [String : Any]),
                      cmd.cmd == PanoMsgType.uploadAudioLog else {
                    return
                }
                PanoAudioService.service()?.startAudioDump(timeinterval: 60)
                self.uploadlogType = cmd.cmd
            }
        }
    }
    
    // MARK: PanoRtcEngineDelegate
    func onUserJoinIndication(_ userId: UInt64, withName userName: String?) {
        PanoUserService.service()?.onUserJoinIndication(userId, withName: userName)
    }
    
    func onChannelJoinConfirm(_ result: PanoResult) {
        DispatchQueue.main.async {
            guard PanoClientService.joined else { return }
            print("joinChannel end -> \(result.rawValue)",NSDate())
            self.joinCompletion?(result == .OK)
            self.joinCompletion = nil
            if result == .OK {
                PanoAudioService.service()?.startAudio(mute: self.config.userMode != .anchor)
                PanoAudioService.service()?.setLoudspeakerStatus(staus: true)
                self.engineKit?.setAudioDeviceVolume(125, with: .audioPlayout)
                PanoPlayerService.service()?.loadMusicResouces()
                self.initAudioChanger()
            } else {
                self.delegates.invokeDelegates { (del) in
                    del.showExitRoomAlert(message: nil)
                }
            }
        }
    }
    
    func onUserLeaveIndication(_ userId: UInt64, with reason: PanoUserLeaveReason) {
        PanoUserService.service()?.onUserLeaveIndication(userId, with: reason)
    }
    
    func onUserAudioStart(_ userId: UInt64) {
        PanoUserService.service()?.onUserAudioStart(userId)
    }
    
    func onUserAudioStop(_ userId: UInt64)  {
        PanoUserService.service()?.onUserAudioStop(userId)
    }
    
    func onUserAudioMute(_ userId: UInt64) {
        PanoUserService.service()?.onUserAudioMute(userId)
    }
    
    func onUserAudioUnmute(_ userId: UInt64) {
        PanoUserService.service()?.onUserAudioUnmute(userId)
    }
    
    func onChannelCountDown(_ remain: UInt32) {
        // 会议时长结束通知
    }
    
    func onChannelLeaveIndication(_ result: PanoResult) {
        DispatchQueue.main.async {
            print("onChannelLeaveIndication-> \(result.rawValue)")
            self.delegates.invokeDelegates { (del) in
                del.showExitRoomAlert(message: "你已离开通话，请点击确认回到首页")
            }
            self.leaveAudioRoom()
        }
    }
    
    func onUserAudioLevel(_ level: PanoRtcAudioLevel) {
        guard PanoClientService.joined else { return }
        PanoUserService.service()?.onUserAudioLevel(level);
    }
}
