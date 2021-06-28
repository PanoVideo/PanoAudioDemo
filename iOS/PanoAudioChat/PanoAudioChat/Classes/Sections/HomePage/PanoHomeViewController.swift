//
//  PanoHomeViewController.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import UIKit

class PanoHomeViewController: PanoBaseViewController {

    var contentView: UIView!
    
    var createAudioRoomBtn: UIButton!
    
    var settingBtn: UIButton!
    
    @objc var joinAudioRoomBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func initViews() {
        super.initViews()
        
        settingBtn = UIButton(type: .custom)
        settingBtn.setImage( UIImage(named: "btn.setting.black"), for: .normal)
        settingBtn.setImage( UIImage(named: "btn.setting.black"), for: .highlighted)
        settingBtn.addTarget(self, action: #selector(showSettingPage), for: .touchUpInside)
        self.view.addSubview(settingBtn)
        
        contentView = UIView()
        self.view.addSubview(contentView)
        
        createAudioRoomBtn = UIButton(type: .custom)
        createAudioRoomBtn.addTarget(self, action: #selector(createRoomAction), for: .touchUpInside)
        createAudioRoomBtn.setTitle("Create a chat room".localized(), for: .normal);
        createAudioRoomBtn.titleLabel?.font = FontMax
        createAudioRoomBtn.titleLabel?.textColor = UIColor.white
        createAudioRoomBtn.setBackgroundImage(UIImage(named: "home_bg_yellow"), for: .normal)
        createAudioRoomBtn.setBackgroundImage(UIImage(named: "home_bg_yellow"), for: .highlighted)
        createAudioRoomBtn.layer.cornerRadius = 8
        createAudioRoomBtn.layer.masksToBounds = true
        contentView.addSubview(createAudioRoomBtn)
        
        joinAudioRoomBtn = UIButton(type: .custom)
        joinAudioRoomBtn.addTarget(self, action: #selector(joinRoomAction), for: .touchUpInside)
        joinAudioRoomBtn.setTitle("Join the chat room".localized(), for: .normal);
        joinAudioRoomBtn.titleLabel?.font = FontMax
        joinAudioRoomBtn.titleLabel?.textColor = UIColor.white
        joinAudioRoomBtn.setBackgroundImage(UIImage(named: "home_bg_blue"), for: .normal)
        joinAudioRoomBtn.setBackgroundImage(UIImage(named: "home_bg_blue"), for: .highlighted)
        joinAudioRoomBtn.layer.cornerRadius = 8
        joinAudioRoomBtn.layer.masksToBounds = true
        contentView.addSubview(joinAudioRoomBtn)
    }
    
    override func initConstraints() {
        
        settingBtn.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview().inset(UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 30))
        }
        contentView.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
            make.left.right.equalToSuperview()
        }
        let inset = UIEdgeInsets(top: 0, left: defaultMargin * 2, bottom: 0, right: defaultMargin * 2)
        createAudioRoomBtn.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview().inset(inset)
            make.height.equalTo(110)
        }
        joinAudioRoomBtn.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview().inset(inset)
            make.height.equalTo(createAudioRoomBtn)
            make.top.equalTo(createAudioRoomBtn.snp.bottom).offset(30)
        }
    }
    
    override func initServices() {
        PanoClientService.checkAppVersion { (forceUpdate) in
            let title = forceUpdate ? "upgradeTitleForce".localized() : "upgradeTitle".localized()
            let msg = forceUpdate ? "upgradeAlertForce".localized() :
                "upgradeAlert".localized()
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            let ok = UIAlertAction(title: "upgrade".localized(), style: .default) { (_) in
                UIApplication.shared.open(URL(string: "https://apps.apple.com/cn/app/pano-audio-chat/id1539620928")!, options: [:], completionHandler: nil)
                if (forceUpdate) {
                    exit(0)
                }
            }
            let cancel = UIAlertAction(title: "notUpgrade", style: .cancel, handler: nil)
            alert.addAction(ok)
            if (!forceUpdate) {
                alert.addAction(cancel)
            }
            if ((self.presentedViewController == nil)) {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func createRoomAction() {
        showJoinPage(userMode: .anchor)
    }
    
    @objc func joinRoomAction() {
        showJoinPage(userMode: .andience)
    }
    
    func showJoinPage(userMode: PanoUserMode) {
        let vc = PanoJoinViewController()
        vc.userMode = userMode
        let navi = PanoBaseNavigationController(rootViewController: vc)
        navi.modalPresentationStyle = .fullScreen
        present(navi, animated: true, completion: nil)
    }
    
    @objc func showSettingPage() {
        let vc = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "setting")
        let navi = PanoBaseNavigationController(rootViewController: vc)
        navi.modalPresentationStyle = .fullScreen
        self.present(navi, animated: true, completion: nil)
    }
}
