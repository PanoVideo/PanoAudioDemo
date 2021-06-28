//
//  PanoAudioRoomPresenter.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import UIKit

public enum PanoActionSheetType : Int {
    case muteUser = 0
    case unmuteUser = 1
    case killUser = 2
}

protocol PanoAudioRoomInterface : NSObjectProtocol {
    
    func showInvitePage(micInfo: PanoMicInfo);
    
    func showApplyAlert(handler: @escaping (_ success: Bool) -> Void);
    
    func cancelApplyAlert();
    
    func showExitAlert(message: String?, handler: @escaping (Bool) -> Void);
    
    func showkickMicActionSheet(mute: Bool, handler: @escaping (PanoActionSheetType) -> Void);
    
    func updateNaviTitleView();
    
    func updateHeaderView(host: PanoUser);
    
    func showInvitedToast();
    
    func showToast(message: String?);

    func showInvitedAlert(message: String?, handler: @escaping (Bool, PanoCmdReason) -> Void);
    
    func showRejectedToast(message: String?);
    
    func updateApplyChatView(applyUsers: [PanoMicInfo]);
    
    func reloadMicQueueView();
    
    func showAudioPanelView();
    
    func reloadControlView();
    
    func exitChat();
}

class PanoAudioRoomPresenter : NSObject {

    var dataSource : PanoAudioRoomDataSource!
    
    weak var delegate: PanoAudioRoomInterface?
    
    var isFirstReceiveMicInfo = true;
    
    init(userMode: PanoUserMode) {
        
        super.init()
        
        dataSource = PanoAudioRoomDataSource()
        dataSource.userMode = userMode
        dataSource.applyArrayDidTrimmed = { [weak self] (micInfos: [PanoMicInfo], reason: PanoCmdReason) in
            self?.reloadApplyView()
            for item in micInfos {
                self?.rejectChat(info: item, reason: reason)
            }
        }
        
        let clientService = PanoServiceManager.service(type: .client) as! PanoClientService
        clientService.delegates.addDelegate(self)
        
        let userService = PanoServiceManager.service(type: .user) as! PanoUserService
        userService.delegates.addDelegate(self)
        
    }
    
    func clientService() ->PanoClientService {
        let clientService =  PanoServiceManager.service(type: .client) as! PanoClientService
        return clientService;
    }
    
    deinit {
        print(self, "deinit")
    }
}


extension PanoAudioRoomPresenter: PanoMicCollectionCellDelegate {
    
    func onMicButtonPressed(micInfo: PanoMicInfo) {
        
        if dataSource.userMode == .anchor {
            if micInfo.status == PanoMicStatus.none {
                delegate?.showInvitePage(micInfo: micInfo)
            } else if micInfo.isOnline() {
                var muteFlag = true
                if let user = micInfo.user {
                    muteFlag = user.audioStatus == .unmute
                }
                delegate?.showkickMicActionSheet(mute: muteFlag, handler: { [weak self] (type) in
                    if type == .killUser {
                        self?.killUser(info: micInfo)
                    } else if type == .muteUser {
                        self?.muteUser(info: micInfo)
                    } else if type == .unmuteUser {
                        self?.unmuteUser(info: micInfo)
                    }
                })
            }
        } else {
            if dataSource.myMicInfo.status == PanoMicStatus.connecting {
                // 您正在连麦中，无法申请上麦
                return
            }
            
            // 如果当前麦位上有人，或者正在申请该麦位
            if (micInfo.isOnline() || micInfo.status == .connecting) &&
                micInfo.userId != dataSource.myMicInfo.userId {
                return
            }
            
            if dataSource.myMicInfo.status == PanoMicStatus.none {
                
                delegate?.showApplyAlert { [weak self] (flag) in
                    self?.dataSource.myMicInfo.status = .connecting
                    self?.dataSource.myMicInfo.order = micInfo.order
                    if let info = self?.dataSource.myMicInfo {
                        self?.applyChat(info: info)
                    }
                    // 已申请上麦，等待通过...
                    
                }
                
            } else if micInfo.status == PanoMicStatus.connecting {
                
                _  = "\(String(describing: micInfo.user?.userName)) 正在申请该麦位";
                
            } else if  micInfo.isOnline() {
                
                //申请下麦
                self.delegate?.exitChat()
            }
        }
    }
}


extension PanoAudioRoomPresenter : PanoUserDelegate {
    
    func onUserAdded(user: PanoUser) {
        delegate?.updateNaviTitleView()
    }
    
    func onUserRemoved(user: PanoUser) {
        remove(user: user)
        delegate?.updateNaviTitleView()
        delegate?.reloadMicQueueView()
    }
    
    func onUserPropertyChanged(user: PanoUser?) {
        reloadView()
        if let host = PanoUserService.service()?.host {
            delegate?.updateHeaderView(host: host)
        }
    }
    
    func onUserAudioLevelChanged() {
        onUserPropertyChanged(user: nil);
    }
}

extension PanoAudioRoomPresenter: PanoClientDelegate {
    
    func showExitRoomAlert(message: String?) {
        delegate?.showExitAlert(message: message ?? "加入房间失败") { (flag) in
        }
    }
    
    func onPropertyChanged(_ value: [String : Any], for key: String) {
        print("v:", value, "key:", key);
        guard key == PanoAllMicKey else {
            return
        }
        guard let cmd = PanoMicMessage(dict: value) else {
            return
        }
        guard !PanoUserService.isHost() else {
            if isFirstReceiveMicInfo {
                isFirstReceiveMicInfo = false
                dataSource.updateMicArray(micInfos: cmd.data as! [PanoMicInfo])
            }
            return
        }
        dataSource.updateMicArray(micInfos: cmd.data as! [PanoMicInfo])
        reloadView()
        let audioService = PanoServiceManager.service(type: .audio) as! PanoAudioService
        switch dataSource.myMicInfo.status {
        case .finished:
            audioService.unmuteAudio()
            break
        default:
            audioService.muteAudio()
        }
    }
    
    func reloadView() {
        delegate?.reloadControlView()
        delegate?.reloadMicQueueView()
    }
    
    func reloadApplyView() {
        delegate?.updateApplyChatView(applyUsers: dataSource.applyMicArray)
    }
    
    /// 更新所有的麦位状态
    func updateAllMicStatus() {
        let value = PanoMicMessage(cmd: .allMic, data: dataSource.totalMicArray).toDictionary()
        _ = clientService().setProperty(value: value, for: PanoAllMicKey)
    }
    
    func onMessageReceived(_ message: [String : Any], fromUser userId: UInt64) {
        print("_onMessageReceived", message, userId)
        if let cmdMsg = PanoCmdMessage(dict: message),
           cmdMsg.cmd == .closeRoom {
            PanoClientService.service().uploadlogsAutomatically()
            delegate?.showExitAlert(message: nil) { (_) in }
            self.leaveRoom()
        }
        guard let micMsg = PanoMicMessage(dict: message) else {
            return
        }
        guard var micInfo = (micMsg.data as? [PanoMicInfo])?.first else {
            return
        }
        guard let curMic = dataSource.micInfo(with: micInfo.order) else {
            return
        }
        let reject = { [weak self] (reason: PanoCmdReason) in
            var tempMicInfo = PanoMicInfo(info: micInfo);
            tempMicInfo.userId = userId
            self?.rejectChat(info: tempMicInfo, reason: reason)
        };
        
        let fromUser = PanoUserService.service()?.findUser(userId: userId)
        switch micMsg.cmd {
        case .applyChat: // 收到发送申请上麦的消息
            guard PanoUserService.isHost() else {
                return
            }
            guard !curMic.isOnline() else {
                reject(.occupied);
                return
            }
            micInfo.status = .connecting
            dataSource.appendApplyUser(with: micInfo)
            reloadApplyView()
            break
        case .acceptChat: // 收到主播同意上麦的消息
            if dataSource.myMicInfo.userId == micInfo.userId{
                delegate?.cancelApplyAlert()
                reloadView()
                PanoAudioService.service()?.unmuteAudio()
            }
            break
        case .rejectChat: // 收到主播拒绝上麦的消息
            if dataSource.myMicInfo.userId == micInfo.userId {
                delegate?.cancelApplyAlert()
                var msg: String? = nil;
                switch micMsg.reason {
                case .timeout:
                    msg = "主播长时间未同意你的申请上麦";
                    break
                case .occupied:
                    msg = "当前麦位被占用";
                    break
                case .ok:
                    msg = nil;
                }
                delegate?.showRejectedToast(message: msg?.localized())
                dataSource.resetMyMic()
            }
        case .rejectInvite: // 收到观众拒绝主播邀请消息
            var msg = "'\(String(describing: fromUser?.userName ?? ""))'" ;
            msg += micMsg.reason == .timeout ? "长时间未接受你的邀请".localized() :                "拒绝了你的邀请".localized();
            delegate?.showToast(message: msg);
            break
        case .cancelChat:
            if let fromUser = fromUser {
                remove(user: fromUser)
            }
        case .stopChat:
            dataSource.updateMicArray(micInfo: PanoMicInfo(status: .none, order: micInfo.order))
            updateAllMicStatus()
            reloadView()
            break
        case .killUser:
            if dataSource.myMicInfo.userId == micInfo.userId {
                PanoAudioService.service()?.muteAudio()
                dataSource.resetMyMic()
                delegate?.showToast(message: "'\(String(describing: fromUser?.userName ?? ""))'" + "您已被主播请下麦位".localized());
            }
            break
        case .acceptInvite: // 收到观众接受主播邀请消息
            guard !curMic.isOnline() else {
                reject(.occupied);
                return
            }
            micInfo.status = PanoMicStatus.finished
            dataSource.updateMicArray(micInfo: micInfo)
            dataSource.removeApplyUser(with: micInfo);
            updateAllMicStatus()
            reloadView()
            break
        case .inviteUser:
            delegate?.showInvitedAlert(message: "主播邀请您上麦".localized(), handler: { [weak self] (flag, reason) in
                if (flag) {
                    self?.acceptInvite(info: micInfo)
                } else {
                    self?.rejectInvite(info: micInfo, reason: reason)
                }
            })
        default:
            break
        }
    }
    
    func remove(user: PanoUser) {
        if PanoUserService.isHost() {
            let contain = dataSource.containUser(user:user)
            dataSource.removeApplyUser(with: user)
            dataSource.removeMicUser(user: user)
            reloadApplyView()
            if contain {
                updateAllMicStatus()
                reloadView()
            }
        }
    }
}


extension PanoAudioRoomPresenter {
    
    func stopChat() {
        stopChat(info: dataSource.myMicInfo)
        dataSource.resetMyMic()
    }
    
    func stopChat(info: PanoMicInfo) {
        _ = clientService().signalService?.sendStopChatMsg(micInfo: info)
    }
    
    func accpetChat(info: PanoMicInfo) {
        dataSource.removeApplyUser(with: info)
        var tempInfo = PanoMicInfo(info: info)
        tempInfo.status = PanoMicStatus.finished
        dataSource.updateMicArray(micInfo: tempInfo)
        updateAllMicStatus()
        reloadView()
        reloadApplyView()
        _ = clientService().signalService?.sendAcceptChatMsg(micInfo: info)
    }
    
    func rejectChat(info: PanoMicInfo, reason: PanoCmdReason = .ok) {
        dataSource.removeApplyUser(with: info, delete: false)
        reloadApplyView()
        _ = clientService().signalService?.sendRejectChatMsg(micInfo: info, reason: reason)
    }
    
    func closeRoomMsg() {
        _ = clientService().signalService?.sendCloseRoomMsg()
    }
    
    func applyChat(info: PanoMicInfo) {
        _ = clientService().signalService?.sendApplyChatMsg(micInfo: info)
        perform(#selector(checkMyApplyStatus), with: nil, afterDelay: TimeInterval(PanoMsgExpireInterval))
    }
    
    @objc func checkMyApplyStatus() {
        if dataSource.myMicInfo.status == .connecting {
            delegate?.cancelApplyAlert()
            delegate?.showRejectedToast(message: "主播长时间未同意你的申请上麦".localized())
            dataSource.resetMyMic()
        }
    }
    
    func cancelChat(info: PanoMicInfo) {
        var tempInfo = PanoMicInfo()
        tempInfo.userId = PanoClientService.service().userId
        dataSource.myMicInfo = tempInfo
        _ = clientService().signalService?.sendCancelChatMsg(micInfo: info)
    }
    
    func muteUser(info: PanoMicInfo)  {
        var temp = PanoMicInfo(info: info)
        temp.status = .finishedMuted
        dataSource.updateMicArray(micInfo: temp)
        updateAllMicStatus()
    }
    
    func unmuteUser(info: PanoMicInfo)  {
        var tempInfo = PanoMicInfo(info: info)
        tempInfo.status = .finished
        dataSource.updateMicArray(micInfo: tempInfo)
        updateAllMicStatus()
    }
    
    func joinAudioRoom(completion: @escaping (Bool) -> Void) {
        let clientService = PanoClientService.service()
        clientService.joinAudioRoom(config: clientService.config) { [weak self] (flag) in
            guard let self = self else { return completion(false) }
            if clientService.config.userMode == PanoUserMode.anchor {
                let user = PanoUser(userId: clientService.config.userId, userName: clientService.config.userName)
                self.delegate?.updateHeaderView(host: user)
            }
            completion(flag)
            print("joinAudioRoom")
        }
    }
    
    func leaveRoom() {
        delegate?.cancelApplyAlert()
        delegate = nil
        PanoClientService.service().leaveAudioRoom()
    }
    /// 主播踢掉某个麦位的用户
    func killUser(info: PanoMicInfo) {
        dataSource.removeMicArray(micInfo: info)
        updateAllMicStatus()
        _ = clientService().signalService?.sendkillMsg(micInfo: info)
        reloadView()
    }
    
    /// 接受主播邀请
    func acceptInvite(info: PanoMicInfo) {
        _ = clientService().signalService?.sendAcceptInviteMsg(micInfo: info)
    }
    
    /// 拒绝主播邀请
    func rejectInvite(info: PanoMicInfo, reason: PanoCmdReason = .ok) {
        _ = clientService().signalService?.sendRejectInviteMsg(micInfo: info, reason: reason)
    }
}


extension PanoAudioRoomPresenter : PanoAudioPlayerDelegate {
    
    func didChooseNextAction() {
        PanoPlayerService.service()?.chooseNextAction()
    }
    
    func didStartPlayAction(pause: Bool) {
        PanoPlayerService.service()?.startPlayAction(pause: pause)
    }
    
    func didShowMoreAction() {
        delegate?.showAudioPanelView()
    }
}



