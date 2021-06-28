//
//  PanoAudioRoomController.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import UIKit
import SimpleAlert
import Toast_Swift
import SnapKit


class PanoAudioRoomController: PanoBaseViewController {

    var naviTitleView: PanoNaviTitleView!
    
    var headerView: PanoRoomHeaderView!
    
    var micQueueView : PanoMicQueueView!
    
    var bgImageView: UIImageView!
    
    var bgBottomImg: UIImageView!
    
    var presenter: PanoAudioRoomPresenter!
    
    var whiteBoradView: UIView!
    
    var applyListView: PanoApplyUserListView!
    
    var myApplyView: PanoMyApplyView!
    
    var audioPlayerView: PanoAudioPlayerView!
    var audioPanelView: PanoAudioPanelView!
    var earMonitoring: PanoEarMonitoring!
    var chatInputView: PanoChatInputView!
    var chatView: PanoChatView!
    var contentView: UIView!
    
    var badgeView: PanoNaviBadgeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default);
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default);
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    override func initViews() {
        
        setBgView()
        setNaviBar()
        
        contentView = UIView()
        self.view.addSubview(contentView)
        
        headerView = PanoRoomHeaderView()
        contentView.addSubview(headerView)
        
        micQueueView = PanoMicQueueView()
        contentView.addSubview(micQueueView)
        
        whiteBoradView = UIView()
        whiteBoradView.isHidden = true
        self.view.addSubview(whiteBoradView)
        
        applyListView = PanoApplyUserListView(frame: .zero) // 已申请的用户
        applyListView.delegate = self
        
        myApplyView = PanoMyApplyView()  // 申请连麦
        
        // 混音页面
        audioPanelView = PanoAudioPanelView(frame: CGRect(x: 0, y:PanoAppHeight, width: PanoAppWidth, height: 100))
        
        // 耳返页面
        earMonitoring = PanoEarMonitoring(frame: CGRect(x: 0, y: PanoAppHeight, width: PanoAppWidth, height: 100))
        
        chatInputView = PanoChatInputView() // 聊天输入框
        chatInputView.delegate = self
        contentView.addSubview(chatInputView)
         
        chatView = PanoChatView() // 聊天页面
        contentView.addSubview(chatView)
        
        audioPlayerView = PanoAudioPlayerView() // 混音控制框
        audioPlayerView.isHidden = true
        contentView.addSubview(audioPlayerView)
    }
    
    func setNaviBar()  {
        self.navigationItem.leftBarButtonItem = nil
        let setting = UIBarButtonItem(image: UIImage(named: "nav_setting"), style: .plain, target: self, action: #selector(showSettingPage))
        let leave = UIBarButtonItem(image: UIImage(named: "navi_leave"), style: .plain, target: self, action: #selector(showLeaveAlert))
        self.navigationItem.rightBarButtonItems = [leave, setting]
        
        self.badgeView = PanoNaviBadgeView(image: UIImage(named: "room_notice")) { [weak self] in
            self?.showApplyChatView()
        };
    }
    
    func setBgView() {
        bgImageView = UIImageView()
        bgImageView.image = UIImage(named: "room_bg")
        self.view.addSubview(bgImageView)
    }
    
    override func initConstraints() {
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        bgImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        headerView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(self.view).inset(UIEdgeInsets(top: topSafeArea(), left: 0, bottom: 0, right: 0))
            make.height.equalTo(180)
        }
        
        micQueueView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(UIEdgeInsets.zero)
            make.height.equalTo(240)
            make.top.equalTo(headerView.snp.bottom)
        }
        
        whiteBoradView.snp.makeConstraints { (make) in
            make.width.height.equalTo(0.1)
            make.left.top.equalToSuperview()
        }
        
        audioPlayerView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(19)
            make.bottom.equalToSuperview().offset(-120)
            make.height.equalTo(39)
        }
        
        chatView.snp.makeConstraints { (make) in
            make.top.equalTo(micQueueView.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(chatInputView.snp.top).offset(-8)
        }
        
        chatInputView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(60)
        }
    }
    
    override func initServices() {
        
        updateNaviTitleView()
        
        let clientService = PanoServiceManager.service(type: .client) as! PanoClientService
        guard let config = clientService.config else {
            return
        }
        presenter = PanoAudioRoomPresenter(userMode: config.userMode)
        presenter.delegate = self
        self.view.makeToastActivity(.center)
        presenter.joinAudioRoom { [weak self] (flag) in
            self?.view.hideToastActivity()
            if !flag {
                self?.showExitAlert(message: "加入房间失败".localized()) { (flag) in
                }
            } else {
                if PanoUserService.isHost(){
                    self?.audioPlayerView.isHidden = false
                    self?.view.hideToastActivity()
                    self?.showTips()
                }
            }
        }
        
        micQueueView.delegate = presenter
        reloadMicQueueView()
        
        self.myApplyView.cancelBlock = { [weak self] in
            if let micInfo = self?.presenter.dataSource.myMicInfo {
                self?.presenter.cancelChat(info: micInfo)
                self?.cancelApplyAlert()
            }
        };
        
        audioPlayerView.delegate = presenter
        
        reloadControlView();
        
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        chatView.initService()
        
        self.audioPanelView.dismissBlock = { [weak self] in
            self?.audioPlayerView.playBtn.isSelected = !PanoPlayerService.service()!.isMusicPlaying();
        };
    }
    
    func showTips() {
        if !PanoClientService.audioAdvanceProcess {
            self.view.showToast(message: "您关闭了音频前处理，建议使用外置声卡。".localized())
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    @objc func showSettingPage() {
        let vc = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "setting")
        let navi = PanoBaseNavigationController(rootViewController: vc)
        navi.modalPresentationStyle = .fullScreen
        self.present(navi, animated: true, completion: nil)
    }
    
    @objc func showLeaveAlert() {
        showExitRoomActionSheet(showStopChat: self.presenter.dataSource.myMicInfo.isOnline())
    }
    
    func showExitRoomActionSheet(showStopChat: Bool = false) {
        let alert = AlertController(title: nil, message: nil, style: .actionSheet)
        let title = PanoUserService.isHost() ? NSLocalizedString("退出并解散房间", comment: "") : NSLocalizedString("离开房间", comment: "")
        alert.addAction(AlertAction(title: title, style: .ok, handler: { [weak self]  (alert) in
            self?.presenter.leaveRoom()
            self?.dismiss()
        }))
        if showStopChat {
            alert.addAction(AlertAction(title: "我要下麦".localized(), style: .default, handler: { [weak self] (action) in
                self?.presenter.stopChat()
            }))
        }
        alert.addAction(AlertAction(title: "取消".localized(), style: .destructive))
        
        present(alert, animated: true, completion: nil)
    }
    
    override func dismiss() {
        self.view.makeToastActivity(.center)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.25) {
            self.view.hideAllToasts()
            super.dismiss()
        }
    }
}

extension PanoAudioRoomController:  PanoAudioRoomInterface {
    
    func reloadControlView() {
        let chating = self.presenter.dataSource.myMicInfo.isOnline()
        chatInputView.updateControlView(isHost: PanoUserService.isHost(), isChating: chating)
    }
 
    func reloadMicQueueView() {
        micQueueView.data = presenter.dataSource.totalMicArray
        micQueueView.reloadData()
    }
    
    @objc func showApplyChatView() {
        if let keyWindow = UIApplication.shared.keyWindow {
            applyListView.showInView(parentView: keyWindow)
        }
    }
    
    func updateApplyChatView(applyUsers: [PanoMicInfo]) {
        if applyUsers.count > 0 {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.badgeView);
            self.badgeView.badgeLabel.text = String(applyUsers.count);
            applyListView.dataSource = applyUsers
            applyListView.reloadView()
        } else {
            self.navigationItem.leftBarButtonItem = nil;
            self.applyListView.dismiss()
        }
    }
    
    func showApplyAlert(handler: @escaping (Bool) -> Void) {
        let alert = AlertController(title: nil, message: NSLocalizedString("申请上麦", comment: ""), style: .alert)

        alert.addAction(AlertAction(title: "取消".localized(), style: .cancel))
        alert.addAction(AlertAction(title: "确认".localized(), style: .ok, handler: { [weak self] (alert) in
            handler(true)
            if let view = UIApplication.shared.keyWindow {
                self?.myApplyView.showInView(view: view)
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func cancelApplyAlert() {
        self.myApplyView.dismiss()
    }
    
    func showExitAlert(message: String? = nil, handler: @escaping (Bool) -> Void) {
        self.audioPanelView.dismiss()
        let alert = AlertController(title: nil, message: message ?? NSLocalizedString("房间已解散", comment: ""), style: .alert)
        alert.addAction(AlertAction(title: "确认".localized(), style: .ok, handler: { [weak self] (alert) in
            self?.presenter.leaveRoom()
            self?.dismiss()
            handler(true)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showkickMicActionSheet(mute: Bool = true, handler: @escaping (PanoActionSheetType) -> Void) {
        
        let alert = AlertController(title: nil, message: nil , style: .actionSheet)

        if mute {
            alert.addAction(AlertAction(title: "闭麦".localized(), style: .ok, handler: { (alert) in
                handler(.muteUser)
            }))
        } else {
            alert.addAction(AlertAction(title: "开麦".localized(), style: .ok, handler: { (alert) in
                handler(.unmuteUser)
            }))
        }
        
        alert.addAction(AlertAction(title: "强制下麦".localized(), style: .ok, handler: { (alert) in
            handler(.killUser)
        }))
        
        alert.addAction(AlertAction(title: "取消".localized(), style: .cancel))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showInvitePage(micInfo: PanoMicInfo) {
        let vc = PanoInviteListViewController()
        vc.micInfo = micInfo
        vc.onlineUser = self.presenter.dataSource.onlineUser()
        let nav = PanoBaseNavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
    func updateNaviTitleView() {
        let clientService = PanoServiceManager.service(type: .client) as! PanoClientService
        let userService = PanoServiceManager.service(type: .user) as! PanoUserService
        let subTitle = "\(userService.totalCount())" + NSLocalizedString("人在线", comment:"")
        let titleView = PanoNaviTitleView(title: clientService.config.roomId, subTitle: subTitle)
        self.navigationItem.titleView = titleView.naviTitleView()
    }
    
    func updateHeaderView(host: PanoUser) {
//        print("host: \(host)")
        headerView.nameLabel.text = host.userName
        self.view.hideToastActivity()
        self.headerView.update()
    }
    
    func showInvitedToast() {
        self.view.makeToast("你被主播邀请上线".localized(), duration: 3, position: .center, title: nil, image: nil, style: ToastStyle(), completion: nil)
    }
    
    func showToast(message: String?) {
        self.view.makeToast(message, duration: 3, position: .center, title: nil, image: nil, style: ToastStyle(), completion: nil)
    }
    
    func showInvitedAlert(message: String?, handler: @escaping (Bool, PanoCmdReason) -> Void) {
        
        let alert = AlertController(title: nil, message: message , style: .alert)

        alert.addAction(AlertAction(title: "拒绝".localized(), style: .cancel, handler: { (alert) in
            handler(false, .ok)
        }))
        
        alert.addAction(AlertAction(title: "接受".localized(), style: .ok, handler: { (alert) in
            handler(true, .ok)
        }))
        present(alert, animated: true, completion: nil)
        
        weak var weakAlert = alert;
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + TimeInterval(PanoMsgExpireInterval)) {
            if weakAlert != nil {
                weakAlert?.dismiss(animated: true, completion: nil);
                handler(false, .timeout)
            }
        }
    }

    func showRejectedToast(message: String?) {
        self.view.makeToast(message ?? "主播拒绝了你的申请".localized(), duration: 3, position: .center, title: nil, image: nil, style: ToastStyle(), completion: nil)
    }
    
    func showAudioPanelView() {
        if let keyWindow = UIApplication.shared.keyWindow {
            self.chatInputView.textView.resignFirstResponder()
            self.audioPanelView.showInView(parentView: keyWindow)
        }
    }
    
}


extension PanoAudioRoomController : PanoApplyUserListDelegate {
    func onClickAcceptButton(info: PanoMicInfo!) {
        self.presenter.accpetChat(info: info)
    }
    
    func onClickRejectButton(info: PanoMicInfo!) {
        self.presenter.rejectChat(info: info)
    }
}


extension PanoAudioRoomController : PanoChatInputViewDelegate {
    
    func didSendText(text: String) {
        PanoChatService.service()?.sendTextMessage(text: text)
    }
    
    func keyboardWillShow(height: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.contentView.transform = CGAffineTransform(translationX: 0, y: -height)
        }
    }
    
    func keyboardWillHide() {
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.contentView.transform = CGAffineTransform.identity
        }
    }
    
    func showEarMonitoringView() {
        if let keyWindow = UIApplication.shared.keyWindow {
            self.earMonitoring.showInView(parentView: keyWindow)
        }
    }
    
    func exitChat() {
        let alert = AlertController(title: nil, message: nil, style: .actionSheet)
        let title =  NSLocalizedString("我要下麦".localized(), comment: "")
        alert.addAction(AlertAction(title: title, style: .ok, handler: { [weak self] (alert) in
            self?.presenter.stopChat()
        }))
        alert.addAction(AlertAction(title: "取消".localized(), style: .destructive))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func hideKeyboard() {
        chatInputView.textView.resignFirstResponder()
    }
    
    func toggleAudio() -> Bool {
        if presenter.dataSource.myMicInfo.status == .finishedMuted {
            self.view.showToast(message: "主播禁止你发言".localized())
            return true
        }
        PanoAudioService.service()?.toggleAudio()
        return PanoAudioService.service()?.isMuted ?? true
    }
}
