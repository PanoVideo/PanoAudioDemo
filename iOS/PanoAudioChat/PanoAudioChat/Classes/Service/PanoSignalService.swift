//
//  PanoCmdMsgService.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2021/6/11.
//

import Foundation


class PanoSignalService {
    
    var signalService: PanoSignalInterface {
        get {
            return PanoServiceManager.service(type: .client) as! PanoSignalInterface;
        }
    }
    
    func sendInviteMsg(micInfo: PanoMicInfo) -> Bool {
        let params = PanoMicMessage(cmd: .inviteUser, data: [micInfo]).toDictionary()
        return self.signalService.sendMessage(msg: params, toUser:  micInfo.userId)
    }
    
    func sendAcceptInviteMsg(micInfo: PanoMicInfo) -> Bool {
        let params = PanoMicMessage(cmd: .acceptInvite, data: [micInfo]).toDictionary()
        return self.signalService.sendMessage(msg: params, toUser:  PanoClientService.hostUserId)
    }
    
    func sendRejectInviteMsg(micInfo: PanoMicInfo, reason: PanoCmdReason) -> Bool {
        let params = PanoMicMessage(cmd: .rejectInvite, data: [micInfo], reason: reason).toDictionary()
        return self.signalService.sendMessage(msg: params, toUser:  PanoClientService.hostUserId)
    }
    
    func sendkillMsg(micInfo: PanoMicInfo) -> Bool {
        let params = PanoMicMessage(cmd: .killUser, data: [micInfo]).toDictionary()
        return self.signalService.sendMessage(msg: params, toUser:  micInfo.userId)
    }
    
    func sendApplyChatMsg(micInfo: PanoMicInfo) -> Bool {
        let params = PanoMicMessage(cmd: .applyChat, data: [micInfo]).toDictionary()
        return self.signalService.sendMessage(msg: params, toUser:  PanoClientService.hostUserId)
    }
    
    func sendCancelChatMsg(micInfo: PanoMicInfo) -> Bool {
        let params = PanoMicMessage(cmd: .cancelChat, data: [micInfo]).toDictionary()
        return self.signalService.sendMessage(msg: params, toUser:  PanoClientService.hostUserId)
    }
    
    func sendAcceptChatMsg(micInfo: PanoMicInfo) -> Bool {
        let params = PanoMicMessage(cmd: .acceptChat, data: [micInfo]).toDictionary()
        return self.signalService.sendMessage(msg: params, toUser: micInfo.userId)
    }
    
    func sendRejectChatMsg(micInfo: PanoMicInfo, reason: PanoCmdReason = .ok) -> Bool {
        let params = PanoMicMessage(cmd: .rejectChat, data: [micInfo], reason: reason).toDictionary()
        return self.signalService.sendMessage(msg: params, toUser:  micInfo.userId)
    }
    
    func sendStopChatMsg(micInfo: PanoMicInfo) -> Bool {
        let params = PanoMicMessage(cmd: .stopChat, data: [micInfo]).toDictionary()
        return self.signalService.sendMessage(msg: params, toUser:  PanoClientService.hostUserId)
    }
    
    func sendCloseRoomMsg() -> Bool {
        return self.signalService.broadcastMessage(msg: PanoMicMessage(cmd: .closeRoom).toDictionary())
    }
}
