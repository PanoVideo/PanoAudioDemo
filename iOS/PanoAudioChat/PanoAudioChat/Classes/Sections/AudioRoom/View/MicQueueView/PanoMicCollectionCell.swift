//
//  PanoMicCollectionCell.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import UIKit

protocol PanoMicCollectionCellDelegate : NSObjectProtocol {
    
    func onMicButtonPressed(micInfo: PanoMicInfo);
}


class PanoMicCollectionCell: UICollectionViewCell {
    
    var micButton: PanoMicButton!
    
    var nameLabel: UILabel!
    
    var audioImage: UIImageView!
    
    var moreButton: UIButton!
    
    weak var delegate: PanoMicCollectionCellDelegate?
    
    var micInfo: PanoMicInfo!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nameLabel = UILabel()
        nameLabel.textColor = UIColor.white
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.text = NSLocalizedString("申请上麦", comment: "")
        self.contentView.addSubview(nameLabel)
        
        micButton = PanoMicButton(type: .custom)
        micButton.addTarget(self, action: #selector(micClickAction), for: .touchUpInside)
        micButton.setImage(UIImage(named: "room_invite"), for: .normal)
        self.contentView.addSubview(micButton)
        
        audioImage = UIImageView()
        audioImage.image = UIImage(named: "room_audio_mute")
        audioImage.isHidden = true
        self.contentView.addSubview(audioImage)
        
        moreButton = UIButton(type: .custom)
        moreButton.addTarget(self, action: #selector(moreButtonAction), for: .touchUpInside)
        moreButton.setImage(UIImage(named: "room_avator_more"), for: .normal)
        moreButton.isHidden = true
        self.contentView.addSubview(moreButton)
        
        micButton.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.height.equalTo(micButton.snp.width)
        }
        
        audioImage.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.top.equalTo(micButton.snp.bottom).offset(-10)
            make.centerX.equalTo(micButton)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5)
            make.left.right.equalToSuperview()
        }
        
        moreButton.snp.makeConstraints { (make) in
            make.left.top.equalTo(micButton).inset(UIEdgeInsets(top: 20 , left: 20, bottom: 0, right: 0))
            make.size.equalTo(CGSize(width: 19, height: 19));
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func micClickAction() {
        delegate?.onMicButtonPressed(micInfo: micInfo)
    }
    
    @objc func moreButtonAction() {
        
    }
}


extension PanoMicCollectionCell {
    
    func updateMicInfo(info: PanoMicInfo) {
        micInfo = info
//        nameLabel.text = ""
        audioImage.isHidden = true
        moreButton.isHidden = true
        switch micInfo.status {
        case .none?:
            micButton.setImage(UIImage(named: "room_invite"), for: .normal)
            if PanoUserService.isHost() {
                nameLabel.text = NSLocalizedString("邀请上麦", comment: "")
            } else {
                nameLabel.text = NSLocalizedString("申请上麦", comment: "")
            }
            micButton.stopAnimating()
            break
        case .connecting, .finished, .finishedMuted:
            if micInfo.status == .connecting {
                nameLabel.text = NSLocalizedString("申请中...", comment: "")
                micButton.stopAnimating()
            }
            // print("info.user->", info.userId, info.user?.userName)
            if let user = info.user {
                micButton.setImage(user.avatorImage(), for: .normal)
                micButton.setImage(user.avatorImage(), for: .highlighted)
                if micInfo.isOnline() {
                    audioImage.isHidden = user.audioStatus == .unmute
                    nameLabel.text = user.userName
                    if micInfo.user!.isActiving() {
                        micButton.startAnimating()
                    } else {
                        micButton.stopAnimating()
                    }
                }
            } else {
                micButton.setImage(UIImage(named: "room_invite"), for: .normal)
            }
            break
        default:
            micButton.setImage(UIImage(named: "room_invite"), for: .normal)
            break
        }
    }
}
