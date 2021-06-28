//
//  PanoClientService+App.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2021/6/11.
//

import Foundation

extension PanoClientService {
    
    static let kUserUniqueIDKey = "UUID";
    static let kUserNameKey = "com.pac.UserName";
    static let kDebugKey = "com.pac.debug"
    static let kRoomIdKey = "com.pac.roomID"
    static let kUserIdKey = "com.pac.userID"
    
    static let kAudioAdvanceProcess = "com.pac.audioAdvanceProcess"
    static let kAudioVoiceChanger = "com.pac.audioVoiceChanger"
    
    @objc static var uuid: String = ""
    @objc static var userName = ""
    @objc static var debug: Bool = false
    @objc static var roomId = ""
    @objc static var userId: UInt64 = 0
    @objc static var audioAdvanceProcess: Bool = true
    static var audioVoiceChanger: PanoAudioVoiceChangerOption = .voiceChangerNone
    
    @objc func sendFeedback(type: PanoFeedbackType,
                            detail: String? ,
                            uploadLogs: Bool,
                            contact: String?) {
        let info = PanoFeedbackInfo()
        info.type = type
        info.productName = AppInfo.productName
        info.detailDescription = detail ?? ""
        info.contact = contact
        info.extraInfo = PanoClientService.uuid
        info.uploadLogs = uploadLogs
        self.engineKit?.sendFeedback(info)
    }
    
    @objc func productVersion() -> String {
        let appVersion = AppInfo.appVersion;
        let sdkVersion = PanoRtcEngineKit.getSdkVersion();
        return "v\(appVersion) \(sdkVersion)"
    }
    
    open class func checkUUID() {
        let uuId = UserDefaults.standard.string(forKey: PanoClientService.kUserUniqueIDKey)
        if let id = uuId {
            PanoClientService.uuid = id
        } else {
            PanoClientService.uuid = NSUUID().uuidString
            UserDefaults.standard.setValue(PanoClientService.uuid, forKey: PanoClientService.kUserUniqueIDKey)
        }
    }
    
    open class func loadPreferences() {
        checkUUID()
        PanoClientService.userName = UserDefaults.standard.string(forKey: PanoClientService.kUserNameKey) ?? ""
        PanoClientService.debug = UserDefaults.standard.bool(forKey: PanoClientService.kDebugKey)
        PanoClientService.roomId = UserDefaults.standard.string(forKey: PanoClientService.kRoomIdKey) ?? ""
        PanoClientService.userId = UInt64(UserDefaults.standard.integer(forKey: PanoClientService.kUserIdKey))
        
        if let _ = UserDefaults.standard.value(forKey: PanoClientService.kAudioAdvanceProcess) {
            audioAdvanceProcess = UserDefaults.standard.bool(forKey: PanoClientService.kAudioAdvanceProcess)
        }
        
        PanoClientService.audioVoiceChanger = PanoAudioVoiceChangerOption(rawValue: UserDefaults.standard.integer(forKey: PanoClientService.kAudioVoiceChanger)) ?? .voiceChangerNone
    }
    
    @objc open class func savePreferences() {
        UserDefaults.standard.setValue(PanoClientService.userName, forKey: PanoClientService.kUserNameKey)
        UserDefaults.standard.setValue(PanoClientService.debug, forKey: PanoClientService.kDebugKey)
        UserDefaults.standard.setValue(PanoClientService.roomId, forKey: PanoClientService.kRoomIdKey)
        UserDefaults.standard.setValue(PanoClientService.userId, forKey: PanoClientService.kUserIdKey)
        
        UserDefaults.standard.setValue(PanoClientService.audioAdvanceProcess, forKey: PanoClientService.kAudioAdvanceProcess)
        UserDefaults.standard.setValue(PanoClientService.audioVoiceChanger.rawValue, forKey: PanoClientService.kAudioVoiceChanger)
        
        if PanoClientService.debug {
            PanoAudioService.service()?.startAudioDump()
        } else {
            PanoAudioService.service()?.stopAudioDump()
        }
    }
    
//    自动上传日志
    func uploadlogsAutomatically() {
        if uploadlogType != nil {
            uploadlogType = nil;
            sendFeedback(type: PanoFeedbackType.audio, detail: "\(config.userName) 自动上传日志: " + (uploadlogMessage ?? ""), uploadLogs: true, contact: nil)
        }
    }
    
    @objc func notifyOthersUploadLogs(type: PanoFeedbackType, message: String) {
        uploadlogMessage = message
        _ = self.broadcastMessage(msg: PanoCmdMessage(cmd: .uploadAudioLog).toDictionary())
    }
    
    @objc open class func setAudioVoiceChangerMode(mode: PanoAudioVoiceChangerOption) {
        PanoClientService.audioVoiceChanger = mode
        PanoClientService.rtcEngineKit()?.setOption(mode.rawValue as NSObject, for: .optionAudioVoiceChangerMode)
    }
    
    public static func checkAppVersion(handler: @escaping (_ forceUpdate: Bool) -> Void) {
        // TODO 
    }
}
