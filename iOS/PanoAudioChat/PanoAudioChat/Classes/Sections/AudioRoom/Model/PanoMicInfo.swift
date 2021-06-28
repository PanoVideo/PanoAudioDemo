//
//  PanoMicInfo.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import UIKit


/// 麦位信息
struct PanoMicInfo : Equatable {

    var status: PanoMicStatus!
    
    var userId: UInt64! = 0;
    
    var user: PanoUser? {
        return PanoUserService.service()?.findUser(userId: userId)
    }

    var order: Int!
    
    var timestamp: UInt64? = 0
    
    init(status: PanoMicStatus = .none,
         userId: UInt64? = 0,
         order: Int? = -1)
    {
        self.status = status
        self.userId = userId
        self.order = order
    }
    
    init(info: PanoMicInfo) {
        self.userId = info.userId
        self.status = info.status
        self.order = info.order
    }
    
    /// PanoMicInfo  Dictionary -> Model
    init?(dict: [String: Any]) {
        guard let userId = dict["userId"],
              let status = dict["status"],
              let order = dict["order"] else {
            return nil
        }
        self.userId = userId as? UInt64;
        self.status = PanoMicStatus(rawValue: status as! Int);
        self.order = order as? Int;
    }
    
    /// 是否在麦位上
    func isOnline() -> Bool {
        return self.status == PanoMicStatus.finished ||
               self.status == PanoMicStatus.finishedMuted
    }
    
    /// PanoMicInfo Model -> Dictionary
    func toDictionary() -> [String: Any] {
        return [
            "status" : self.status.rawValue,
            "userId" : self.userId!,
            "order" : self.order!
        ]
    }
    
    // MARK: Equatable
    static func == (lhs: PanoMicInfo, rhs: PanoMicInfo) -> Bool {
        lhs.order == rhs.order
    }
}
