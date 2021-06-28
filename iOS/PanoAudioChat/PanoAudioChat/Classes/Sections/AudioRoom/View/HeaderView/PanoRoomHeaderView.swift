//
//  PanoRoomHeaderView.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import UIKit

class PanoRoomHeaderView: PanoBaseView {

    var nameLabel: UILabel!
    
    var icon: PanoMicButton!
    
    let iconWidth : CGFloat = 85
    
    override func initViews() {
        
        nameLabel = UILabel()
        nameLabel.textColor = UIColor.white
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(nameLabel)
        
        icon = PanoMicButton()
        if PanoUserService.isHost() {
            let image = PanoUserService.avatorImage(userId: PanoClientService.service().userId)
            icon.setImage(image, for: .normal)
            icon.setImage(image, for: .highlighted)
        }
        self.addSubview(icon)
    }
    
    override func initConstraints() {
        icon.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: iconWidth, height: iconWidth))
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(icon.snp.bottom).offset(defaultMargin)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(UIEdgeInsets(top: 0, left: defaultMargin, bottom: 0, right: defaultMargin))
        }
    }
    
    func update() {
        if let user = PanoUserService.service()?.host {
            let image = user.avatorImage()
            icon.setImage(image, for: .normal)
            icon.setImage(image, for: .highlighted)
            if user.isActiving() {
                icon.startAnimating()
            } else {
                icon.stopAnimating()
            }
        }
    }

}
