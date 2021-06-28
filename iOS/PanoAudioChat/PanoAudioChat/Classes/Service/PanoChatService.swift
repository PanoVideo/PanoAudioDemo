//
//  PanoChatService.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import UIKit

struct PanoMessage {
    
    var content : String!
    
    public enum PanoChatMessageType : Int {
        case chatMessage = 0
        case systemMessage = 1
    }
    
    var type: PanoChatMessageType!
    
    var fromUser: Int64?
    
    var size: CGSize = .zero
    
    func toSendMessage() -> [String : Any] {
        let data : [String : Any] = [
            PanoMsgUserId : PanoClientService.service().userId,
            PanoMsgChatContent : content ?? ""
        ]
        return PanoCmdMessage(cmd: .normalChat, data: data).toDictionary()
    }
    
    func isMySendMeesage() -> Bool{
        return self.fromUser ?? 0 == PanoClientService.service().userId
    }
    
    mutating func caculateWidth(width: CGFloat){
        let textSize =  NSString(string: self.content).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                                                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                    attributes: [NSAttributedString.Key.font: FontMedium],
                                                    context: nil).size
        size = textSize
    }
}

protocol PanoChatDelegate : NSObjectProtocol {
    func onReceiveMessage(msg: PanoMessage);
}

class PanoChatService: PanoBaseService, PanoUserDelegate, PanoClientDelegate {

    var messages = [PanoMessage]()
        
    weak var delegate: PanoChatDelegate?
    
    override class func service() -> PanoChatService? {
        return PanoServiceManager.service(type: .chat) as? PanoChatService
    }
    
    func start() {
        let userService: PanoUserService = PanoServiceManager.service(type: .user) as! PanoUserService
        
        userService.delegates.addDelegate(self)
        
        PanoClientService.service().delegates.addDelegate(self)
    }
    
    func sendTextMessage(text: String) {
        let msg = PanoMessage(content: text, type: .chatMessage)
        _ = PanoClientService.service().broadcastMessage(msg: msg.toSendMessage())
    }
    
    func sendSystemMessage(text: String) {
        let msg = PanoMessage(content: text, type: .systemMessage)
        delegate?.onReceiveMessage(msg: msg)
    }
    
    // MARK: PanoUserDelegate
    func onUserAdded(user: PanoUser) {
        sendSystemMessage(text: "‘\(user.userName!)’ " + "加入了房间".localized())
    }
    
    func onUserRemoved(user: PanoUser) {
        if let name = user.userName {
            sendSystemMessage(text: "‘\(name)’ " + "离开了房间".localized())
        }
    }
    
    // MARK: PanoClientDelegate
    func onMessageReceived(_ message: [String : Any], fromUser userId: UInt64) {
        guard let cmd = PanoCmdMessage(dict: message),
              cmd.cmd == PanoMsgType.normalChat,
              let data = cmd.data as? [String: Any] else {
            return
        }
        guard let content = data[PanoMsgChatContent] else {
            return
        }
        guard let fromUser = data[PanoMsgUserId] as? Int64 else {
            return
        }
        var textContent = ""
        if let sendUserName = PanoUserService.service()?.findUser(userId: userId)?.userName {
            textContent += sendUserName + ": "
        }
        textContent += content as! String
        let msg = PanoMessage(content: textContent, type: .chatMessage, fromUser: fromUser)
        
        delegate?.onReceiveMessage(msg: msg)
    }
}
