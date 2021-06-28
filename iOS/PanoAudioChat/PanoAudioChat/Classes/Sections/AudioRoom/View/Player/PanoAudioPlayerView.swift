//
//  PanoAudioPlayerView.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/4.
//

import UIKit

protocol PanoAudioPlayerDelegate : NSObjectProtocol {
    
    func didChooseNextAction()
    
    func didStartPlayAction(pause: Bool)
    
    func didShowMoreAction()
}

class PanoAudioPlayerView: PanoBaseView {

    weak var delegate: PanoAudioPlayerDelegate?
    
    var contentView: UIView!
    
    var playBtn: UIButton!
    
    var nextBtn: UIButton!
    
    var audioName: UILabel!
    
    var audioStateLabel: UILabel!
    
    var icon: UIImageView!
    
    override func initViews() {
        
        contentView = UIView()
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 19
        contentView.backgroundColor = UIColor("#577096")
        self.addSubview(contentView)
        
        icon = UIImageView(image: UIImage(named: "room_player_music"))
        contentView.addSubview(icon)
        
        playBtn = UIButton()
        playBtn.setImage(UIImage(named: "room_player_pause"), for: .normal)
        playBtn.setImage(UIImage(named: "room_player_play"), for: .selected)
        playBtn.isSelected = true
        playBtn.addTarget(self, action: #selector(didStartPlayAction(pause:)), for: .touchUpInside)
        self.contentView.addSubview(playBtn)
        
        nextBtn = UIButton()
        nextBtn.setImage(UIImage(named: "room_player_next"), for: .normal)
        nextBtn.setImage(UIImage(named: "room_player_next"), for: .highlighted)
        nextBtn.addTarget(self, action: #selector(didChooseNextAction), for: .touchUpInside)
        self.contentView.addSubview(nextBtn)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showMoreAction)))
        
    }
    
    override func initConstraints() {
        contentView.snp.makeConstraints { (make) in
            make.width.equalTo(120)
            make.edges.equalToSuperview()
        }
        icon.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(3)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
//        audioName.snp.makeConstraints { (make) in
//            make.left.equalTo(icon.snp.right).offset(3)
//            make.top.equalToSuperview()
//            make.width.equalTo(40)
//            make.height.equalTo(19)
//        }
//        audioStateLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(audioName.snp.right).offset(3)
//            make.top.equalToSuperview()
//            make.width.equalTo(40)
//            make.centerY.equalTo(audioName)
//        }
        playBtn.snp.makeConstraints { (make) in
            make.left.equalTo(icon.snp.right).offset(5)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        nextBtn.snp.makeConstraints { (make) in
            make.left.equalTo(playBtn.snp.right).offset(5)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
    }
    
    @objc func didStartPlayAction(pause: Bool) {
        playBtn.isSelected = !playBtn.isSelected
        delegate?.didStartPlayAction(pause: playBtn.isSelected)
    }
    
    @objc func didChooseNextAction() {
        playBtn.isSelected = false
        delegate?.didChooseNextAction()
    }
    
    @objc func showMoreAction() {
        delegate?.didShowMoreAction()
    }
}
