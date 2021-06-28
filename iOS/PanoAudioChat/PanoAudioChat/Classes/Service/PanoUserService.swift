//
//  PanoUserService.swift
//  PanoAudioRoom
//
//  Created by wenhua.zhang on 2020/10/28.
//

import Foundation



public enum PanoUserAudioStatus : Int {
    
    case close = 0
    
    case unmute = 1
    
    case mute = 2
}

class PanoUser : Equatable {
    
    var userId: UInt64 = 0
    
    var userName: String? = ""
    
    var audioStatus: PanoUserAudioStatus = .close
    
    init(userId: UInt64, userName: String?) {
        self.userId = userId
        self.userName = userName
    }
    
    static func == (lhs: PanoUser, rhs: PanoUser) -> Bool {
        return lhs.userId == rhs.userId
    }
}

extension PanoUser {
    func isActiving() -> Bool {
        if let level = PanoUserService.audioLevels[self.userId]  {
            if level > 500 {
                return true
            }
        }
        return false
    }
    
    func avatorImage() -> UIImage! {
        PanoUserService.avatorImage(userId: self.userId)
    }
}


protocol PanoUserInterface {
    
    func me() -> PanoUser?;
    
    func findUser(userId: UInt64) -> PanoUser?;
    
    func allUsers() -> [PanoUser];
    
    func allUserExceptMe() -> [PanoUser]
    
    func totalCount() -> UInt64;
    
}

protocol PanoUserDelegate  {
    
    func onUserAdded(user: PanoUser);
    
    func onUserRemoved(user: PanoUser);
    
    func onUserPropertyChanged(user: PanoUser?);
    
    func onUserAudioLevelChanged();
}

extension PanoUserDelegate {
    
    func onUserPropertyChanged(user: PanoUser?) { };
    
    func onUserAudioLevelChanged() {};
}

class PanoUserService : PanoBaseService, PanoRtcEngineDelegate
{
    static var audioLevels = [UInt64 : UInt32]()
    
    var lastSpeakTime: Date? = nil
    
    lazy var _dataSource : [PanoUser] = []
    
    typealias ObjectType = PanoUserDelegate
    
    var delegates = MulticastDelegate<PanoUserDelegate>();
    
    override class func service() -> PanoUserService? {
        return PanoServiceManager.service(type: .user) as? PanoUserService
    }
    
    override func uninit() {
        self.delegates.removeAllDelegates()
    }
    
    private func notifyRefresh(user: PanoUser?) {
        guard PanoClientService.joined else { return }
        self.delegates.invokeDelegates { (del) in
            del.onUserPropertyChanged(user: user ?? PanoUser(userId: 0, userName: nil))
        }
    }
    
    //MARK: PanoRtcEngineDelegate
    func onUserJoinIndication(_ userId: UInt64, withName userName: String?) {
        DispatchQueue.main.async {
            let user = PanoUser(userId: userId, userName: userName)
            let clientService = PanoServiceManager.service(type: PanoServiceManager.PanoServiceType.client) as! PanoClientService;
            if userId == clientService.userId {
                self._dataSource.insert(user, at: 0)
            } else {
                self._dataSource.append(user)
            }
            print("onUserJoinIndication \(userId) userName: \(String(describing: userName))")
            self.delegates.invokeDelegates { (del: PanoUserDelegate) in
                del.onUserAdded(user: user)
            }
        }
    }
    
    
    func onUserLeaveIndication(_ userId: UInt64, with reason: PanoUserLeaveReason) {
        DispatchQueue.main.async {
            guard PanoClientService.joined else { return }
            let removeUser = PanoUser(userId: userId, userName: nil)
            
            if let index = self._dataSource.firstIndex(of: removeUser) {
                removeUser.userName = self._dataSource[index].userName
                self._dataSource.remove(at: index)
            }
            
            self.delegates.invokeDelegates { (del) in
                del.onUserRemoved(user: removeUser)
            }
        }
    }
    
    func onUserAudioStart(_ userId: UInt64) {
        DispatchQueue.main.async {
            let user = self.findUser(userId: userId)
            user?.audioStatus = PanoUserAudioStatus.unmute
            self.notifyRefresh(user: user)
        }
    }
    
    func onUserAudioStop(_ userId: UInt64) {
        DispatchQueue.main.async {
            let user = self.findUser(userId: userId)
            user?.audioStatus = PanoUserAudioStatus.close
            self.notifyRefresh(user: user)
        }
    }
    
    func onUserAudioMute(_ userId: UInt64) {
        DispatchQueue.main.async {
            let user = self.findUser(userId: userId)
            user?.audioStatus = PanoUserAudioStatus.mute
            self.notifyRefresh(user: user)
        }
    }
    
    func onUserAudioUnmute(_ userId: UInt64) {
        DispatchQueue.main.async {
            let user = self.findUser(userId: userId)
            user?.audioStatus = PanoUserAudioStatus.unmute
            self.notifyRefresh(user: user)
        }
    }
    
    func onUserAudioLevel(_ level: PanoRtcAudioLevel) {
        DispatchQueue.main.async {
            PanoUserService.audioLevels[level.userId] = level.level
        }
        if lastSpeakTime == nil {
            lastSpeakTime = Date()
        }
        if Date().timeIntervalSince(lastSpeakTime!) > 1 {
            lastSpeakTime = Date()
            DispatchQueue.main.async {
                self.delegates.invokeDelegates { (del) in
                    del.onUserAudioLevelChanged();
                }
            }
        }
    }
}

extension PanoUserService {

    var host: PanoUser? {
        get {
            findUser(userId: PanoClientService.hostUserId)
        }
    }
    
    func me() -> PanoUser? {
        return _dataSource.first;
    }
    
    func findUser(userId: UInt64) -> PanoUser? {
        for item in _dataSource {
            if item.userId == userId {
                return item
            }
        }
        return nil
    }
    
    func allUsers() -> [PanoUser] {
        return _dataSource
    }
    
    func allUserExceptMe() -> [PanoUser] {
        if self.totalCount() <= 1 {
            return []
        } else {
            let temp =  Array(_dataSource[1..._dataSource.count-1])
            return temp
        }
    }
    
    func totalCount() -> UInt64 {
        return UInt64(_dataSource.count)
    }
    
    static func isHost() -> Bool {
        return PanoClientService.service().config?.userMode == PanoUserMode.anchor
    }
    
    func addDelegate(delegate: PanoUserDelegate) {
        delegates.addDelegate(delegate)
    }
    
    func removeDelegate(delegate: PanoUserDelegate) {
        delegates.removeDelegate(delegate)
    }
}

extension PanoUserService {
    static var avators = [UInt64 : String]()
    static let imagesCount : Int = 22
    static var images = [Bool](repeating: false, count: imagesCount)
    static var isFull = false;
    class func avatorImage(userId: UInt64) -> UIImage! {
        if let imageName = avators[userId] {
            return UIImage(named: imageName)
        }
        
        func hashValue(id: UInt64) -> Int {
            let value = Int(id % UInt64(imagesCount))
            if images[value] == false  {
                images[value] = true
                return value
            }
            for index in 0..<imagesCount {
                if images[index] == false {
                    images[index] = true
                    return index;
                }
            }
            return value
        }
        let value = hashValue(id: userId)
        let prefix = value > 9 ? "" : "0"
        let name = prefix +  String(value)
        avators[userId] = name
        let image = UIImage(named: name)
        return image
    }
}
