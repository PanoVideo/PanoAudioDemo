//
//  PanoChatInputView.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/4.
//

import UIKit
import GrowingTextView

protocol PanoChatInputViewDelegate : NSObjectProtocol {
    
    func didSendText(text: String)
    
    func keyboardWillShow(height: CGFloat)
    
    func keyboardWillHide()
    
    func showEarMonitoringView();
    
    func exitChat();
    
    func toggleAudio() -> Bool;
}

class PanoChatInputView: PanoBaseView {
    
    var textView: GrowingTextView!
    
    var inputContentView: UIView!
    
    var controlView: UIStackView!
    
    var loudspeakerButton: UIButton!
    
    var voiceButton: UIButton!
    
    var earButton: UIButton!
    
//    var exitButton: UIButton!
    
    var sendButton: UIButton!
    
    var sendStackView: UIStackView!
    
    var exit: (() -> Void)? = nil
    
    weak var delegate: PanoChatInputViewDelegate?
    
    override func initViews() {
        
        inputContentView = UIView()
        self.addSubview(inputContentView)
        
        textView = GrowingTextView()
        textView.maxLength = 140
        textView.trimWhiteSpaceWhenEndEditing = false
        textView.placeholder = "聊两句".localized()
        textView.placeholderColor = UIColor(white: 0.8, alpha: 1.0)
        textView.minHeight = 35.0
        textView.maxHeight = 35.0
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.backgroundColor = UIColor.white
        textView.layer.cornerRadius = 4.0
        inputContentView.addSubview(textView)
        
        controlView = UIStackView()
        controlView.axis = .horizontal
        controlView.distribution = .fillEqually
        controlView.spacing = 25;
        self.addSubview(controlView)
        
        loudspeakerButton = createMusicButton(image: UIImage(named: "room_loudspeaker"))
        loudspeakerButton.isSelected = false
        loudspeakerButton.setImage(UIImage(named: "room_loudspeaker_close"), for: .selected)
        loudspeakerButton.isEnabled = PanoIsPhone();
        voiceButton = createMusicButton(image: UIImage(named: "room_voice"))
        voiceButton.setImage(UIImage(named: "room_voice_mute"), for: .selected)
        earButton = createMusicButton(image: UIImage(named: "room_ear_monitor"))
//        exitButton = createMusicButton(image: UIImage(named: "room_exit_chat"))
        loudspeakerButton.addTarget(self, action: #selector(startLoudspeaker), for: .touchUpInside)
        voiceButton.addTarget(self, action: #selector(enableAudio), for: .touchUpInside)
        earButton.addTarget(self, action: #selector(showEarMonitorPage), for: .touchUpInside)
//        exitButton.addTarget(self, action: #selector(exitChat), for: .touchUpInside)
        controlView.addArrangedSubview(loudspeakerButton)
        
        sendStackView = UIStackView()
        sendStackView.axis = .horizontal
        sendButton = createMusicButton(title: "  发送  ".localized(), image: nil)
        sendButton.setBackgroundImage(UIImage(named: "home_bg_blue"), for: .normal)
        sendButton.setBackgroundImage(UIImage(named: "home_bg_blue"), for: .highlighted)
        sendButton.addTarget(self, action: #selector(sendText), for: .touchUpInside)
        sendButton.layer.cornerRadius = 15
        sendButton.layer.masksToBounds = true
        sendButton.frame = CGRect(x: 0, y: 2.5, width: 120, height: 30)
        sendStackView.addArrangedSubview(sendButton)
        sendStackView.isHidden = true
        self.addSubview(sendStackView)
        self.addNotifications()
    }
    
    func createMusicButton(title: String? = nil ,image: UIImage?) -> UIButton {
        let button = UIButton(type: .custom)
        if let title = title {
            button.setTitle(title, for: .normal);
        }
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(image, for: .normal);
        button.setImage(image, for: .highlighted)
        return button
    }
    
    
    override func initConstraints() {
        inputContentView.snp.makeConstraints { (make) in
            make.bottom.left.equalToSuperview()
            make.height.equalTo(60)
        }
        controlView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-defaultMargin)
            make.height.equalTo(40)
            make.left.equalTo(inputContentView.snp.right).offset(8)
            make.centerY.equalTo(textView)
        }
        
        sendStackView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-defaultMargin)
            make.height.equalTo(30)
            make.left.equalTo(inputContentView.snp.right).offset(8)
            make.centerY.equalTo(textView)
        }
        
        textView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: defaultMargin, bottom: 25, right: 8))
        }
    }
    
    func updateControlView(isHost: Bool, isChating: Bool) {
        if isHost {
            if !controlView.arrangedSubviews.contains(voiceButton) {
                controlView.addArrangedSubview(voiceButton)
            }
            if !controlView.arrangedSubviews.contains(earButton) {
                controlView.addArrangedSubview(earButton)
            }
            
        } else {
            if isChating {
                if !controlView.arrangedSubviews.contains(voiceButton) {
                    controlView.addArrangedSubview(voiceButton)
                }
                if !controlView.arrangedSubviews.contains(earButton) {
                    controlView.addArrangedSubview(earButton)
                }
//                if !controlView.arrangedSubviews.contains(exitButton) {
//                    controlView.addArrangedSubview(exitButton)
//                }
            } else {
                voiceButton.removeFromSuperview()
                earButton.removeFromSuperview()
//                exitButton.removeFromSuperview()
//                print("controlView.arrangedSubviews-> \(controlView.arrangedSubviews)")
            }
        }
        
        voiceButton.isSelected = PanoUserService.service()?.me()?.audioStatus == .mute
        
    }
    @objc func sendText() {
        if textView.text.isEmpty {
            return
        }
        delegate?.didSendText(text: textView.text)
        textView.text = ""
        textView.resignFirstResponder()
    }
    
    @objc func startLoudspeaker() {
        loudspeakerButton.isSelected = !loudspeakerButton.isSelected
        PanoAudioService.service()?.setLoudspeakerStatus(staus: !loudspeakerButton.isSelected)
    }
    
    @objc func enableAudio() {
        voiceButton.isSelected = self.delegate!.toggleAudio()
//        voiceButton.isSelected = self.toggleAudioBlock!();
//        voiceButton.isSelected = !voiceButton.isSelected
//        if voiceButton.isSelected {
//            PanoAudioService.service()?.muteAudio()
//        } else {
//            PanoAudioService.service()?.unmuteAudio()
//        }
    }
    
    @objc func showEarMonitorPage() {
        delegate?.showEarMonitoringView()
    }
    
    @objc func exitChat() {
        delegate?.exitChat();
    }
    
    deinit {
        self.removeNotifications()
    }
}


extension PanoChatInputView {
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    func removeNotifications() {
            NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        let keyboardHeight = keyboardSize.height;
        delegate?.keyboardWillShow(height: keyboardHeight)
        UIView.animate(withDuration: 0.3) {
            self.sendStackView.isHidden = false
            self.controlView.isHidden = true
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        delegate?.keyboardWillHide()
        UIView.animate(withDuration: 0.3) {
            self.sendStackView.isHidden = true
            self.controlView.isHidden = false
        }
    }
}
