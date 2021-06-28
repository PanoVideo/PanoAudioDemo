//
//  PanoAudioRoomDataSource.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import UIKit

// 主播维护麦位列表
class PanoAudioRoomDataSource: NSObject {
    
    // 总共的麦位数量
    let totalMicCount = 8
    
    // 8个麦位
    var totalMicArray = [PanoMicInfo]()
    
    // 申请上麦的用户
    var applyMicArray = [PanoMicInfo]()
    
    var userMode : PanoUserMode!
    
    // 我自己的麦位信息
    var myMicInfo: PanoMicInfo!
    
    //
    var applyArrayDidTrimmed: ((_ micInfos: [PanoMicInfo], _ reason:PanoCmdReason) -> Void)? = nil
    
    override init() {
        super.init()
        commitInit()
    }
    
    deinit {
        print("PanoAudioRoomDataSource deinit")
    }
    
    private func commitInit() {
        
        myMicInfo = PanoMicInfo()
        
        myMicInfo.userId = PanoClientService.service().userId
        
        // 初始化麦位信息
        for index in 0..<totalMicCount {
            var micInfo = PanoMicInfo()
            micInfo.order = index
            totalMicArray.append(micInfo)
        }
    }
    
    func resetMyMic() {
        myMicInfo.status = PanoMicStatus.none;
        myMicInfo.order = -1;
    }
    
    func micInfo(with order: Int) -> PanoMicInfo? {
        guard order >= 0 && order < totalMicCount else {
            return nil
        }
        return totalMicArray[order]
    }
    
    /// 删除申请者
    func removeApplyUser(with user: PanoUser) {
        applyMicArray.removeAll { $0.userId == user.userId }
    }
    
    /// 删除申请者
    func removeApplyUser(with mic: PanoMicInfo, delete all: Bool = true) {
        if all {
            let needTrimArray = applyMicArray.filter { $0.order == mic.order && $0.userId != mic.userId }
            applyArrayDidTrimmed?(needTrimArray, .ok)
            applyMicArray.removeAll { $0.order == mic.order }
        } else {
            if let i = applyMicArray.firstIndex(of: mic) {
                applyMicArray.remove(at: i)
            }
        }
    }
    
    /// 缓存申请用户
    func appendApplyUser(with mic: PanoMicInfo) {
        applyMicArray.removeAll { $0.userId == mic.userId }
        applyMicArray.append(mic)
        let curTimestamp = UInt64(Date().timeIntervalSince1970)
        if let lastTime = mic.timestamp {
            let delay = TimeInterval(lastTime / 1000  + PanoMsgExpireInterval - curTimestamp)
            perform(#selector(trimApplyUser), with: nil, afterDelay: delay)
        }
    }
    
    /// 删除过期的申请用户
    @objc private func trimApplyUser() {
        let curTimestamp = UInt64(Date().timeIntervalSince1970)
        var needTrimArray = [PanoMicInfo]()
        applyMicArray.removeAll { (mic) -> Bool in
            if let t = mic.timestamp, t / 1000 + PanoMsgExpireInterval <= curTimestamp {
                needTrimArray.append(mic)
                return true
            }
            return false
        }
        applyArrayDidTrimmed?(needTrimArray, .timeout)
    }
    
    /// 更新麦位信息
    func updateMicArray(micInfo: PanoMicInfo) {
        guard micInfo.order >= 0 && micInfo.order < totalMicCount else {
            return
        }
        totalMicArray[micInfo.order] = micInfo
        if myMicInfo.userId == micInfo.userId {
            myMicInfo.status = micInfo.status
            myMicInfo.order = micInfo.order
        }
    }
    
    /// 更新所有麦位信息
    func updateMicArray(micInfos: [PanoMicInfo]) {
        guard micInfos.count == totalMicCount else {
            return
        }
        for item in micInfos {
            updateMicArray(micInfo: item)
        }
    }
    
    /// 删除某个麦位
    func removeMicArray(micInfo: PanoMicInfo) {
        updateMicArray(micInfo: PanoMicInfo(status: .none, order: micInfo.order))
    }
    
    
    /// 删除麦位用户
    func removeMicUser(user: PanoUser) {
        if user.userId == myMicInfo.userId{
            myMicInfo.status = PanoMicStatus.none
            myMicInfo.order = -1
        }
        
        for index in 0..<totalMicCount {
            let info = totalMicArray[index]
            if info.userId == user.userId {
                var tempMicInfo = PanoMicInfo()
                tempMicInfo.order = index
                totalMicArray[index] = tempMicInfo
                break
            }
        }
    }
    
    /// 所有麦位在线的用户
    func onlineUser() -> [PanoUser] {
        var result = [PanoUser]()
        for index in 0..<totalMicCount {
            let info = totalMicArray[index]
            if let user = info.user {
                result.append(user)
            }
        }
        return result
    }
    
    func containUser(user: PanoUser) -> Bool {
        for index in 0..<totalMicCount {
            let info = totalMicArray[index]
            if info.userId == user.userId {
                return true
            }
        }
        return false
    }
}
