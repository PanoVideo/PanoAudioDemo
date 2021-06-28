//
//  PanoJoinViewController.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import UIKit
import Toast_Swift

class PanoJoinViewController: PanoBaseViewController, UITextFieldDelegate {

    public var userMode: PanoUserMode = .anchor
    
    var joinRoomTF: PanoTextField!
    
    var userNameTF: PanoTextField!
    
    var joinBtn: UIButton!
    
    let currentUserId = 0;
        
    override func initViews() {
        super.initViews()
        self.title = userMode == .anchor ? "Create a chat room".localized() :
        "Join the chat room".localized()
        
        joinRoomTF = PanoTextField()
        joinRoomTF.textfiled.keyboardType = .asciiCapable
        joinRoomTF.leftLabel.text = NSLocalizedString("房间号", comment: "");
        joinRoomTF.textfiled.placeholder = NSLocalizedString("输入房间ID/房间号", comment: "");
        self.view.addSubview(joinRoomTF)
        joinRoomTF.textfiled.delegate = self
        
        if userMode != .anchor {
            joinRoomTF.textfiled.text = PanoClientService.roomId
        }
        
        userNameTF = PanoTextField()
        userNameTF.leftLabel.text = NSLocalizedString("用户名", comment: "");
        userNameTF.textfiled.placeholder = NSLocalizedString("输入昵称", comment: "");
        self.view.addSubview(userNameTF)
        
        userNameTF.textfiled.text = PanoClientService.userName
        
        
        let joinTitle = userMode == .anchor ? NSLocalizedString("确认创建", comment: "") :
            NSLocalizedString("确认加入", comment: "")
        
        joinBtn = UIButton(type: .custom)
        joinBtn.addTarget(self, action: #selector(join), for: .touchUpInside)
        joinBtn.setTitle(joinTitle, for: .normal);
        joinBtn.titleLabel?.font = FontMedium
        joinBtn.titleLabel?.textColor = UIColor.white
        joinBtn.setBackgroundImage(UIImage(named: "home_bg_blue"), for: .normal)
        joinBtn.setBackgroundImage(UIImage(named: "home_bg_blue"), for: .highlighted)
        joinBtn.layer.masksToBounds = true
        joinBtn.layer.cornerRadius = ButtonCornerRadius
        self.view.addSubview(joinBtn)
    }
    
    override func initConstraints() {
        super.initConstraints()
        
        joinRoomTF.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview().inset(UIEdgeInsets(top: 120, left: defaultMargin, bottom: 0, right: defaultMargin))
        }
        
        userNameTF.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(UIEdgeInsets(top: 0, left: defaultMargin, bottom: 0, right: defaultMargin))
            make.top.equalTo(joinRoomTF.snp.bottom).offset(30)
        }
        
        joinBtn.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(UIEdgeInsets(top: 0, left: defaultMargin, bottom: 0, right: defaultMargin))
            make.top.equalTo(userNameTF.snp.bottom).offset(30)
            make.height.equalTo(ButtonHeight)
        }
    }
    
    @objc func join() {
        let userName = userNameTF.textfiled.text!
        let roomId = joinRoomTF.textfiled.text!
                
        guard userName.count > 0 && roomId.count > 0 else {
            self.view.makeToast(NSLocalizedString("请输入房间号和用户名", comment: ""), duration: 3, position: .center, title: nil, image: nil, style: ToastStyle(), completion: nil)
            return
        }
        
        let clientService = PanoClientService.service()
        var userId = PanoClientService.userId
        if userId == 0 {
            userId = randomUserId()
        }
        let config = PanoClientConfig(userName:userName, roomId:roomId , userId: userId, userMode: userMode)
        clientService.config = config
        
        let vc = PanoAudioRoomController()
        let nav = PanoBaseNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func randomUserId() -> UInt64 {
        // 请输入加入房间的用户ID, 用于信令通信
        return <#T##UserId: UInt64##UInt64#>
//        let baseRandom : UInt64 = 1000000;
//        let baseId : UInt64 = 11 * baseRandom;
//        return baseId + UInt64(arc4random()) % baseRandom;
    }
    
    /// MARK
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField != joinRoomTF.textfiled {
            return true
        }
        guard let text = textField.text else {
            return false
        }
        
        if text.count >= 20 && !string.elementsEqual("") {
            return false
        }
        
        if isInputCharAvailable(str: string) {
            return true
        }
        return false
    }
    
    func isInputCharAvailable(str: String) -> Bool {

        let predicate = NSPredicate(format: "SELF MATCHES '^[0-9a-zA-Z]*$'")
        let result = predicate.evaluate(with: str)
        return result
    }

}
