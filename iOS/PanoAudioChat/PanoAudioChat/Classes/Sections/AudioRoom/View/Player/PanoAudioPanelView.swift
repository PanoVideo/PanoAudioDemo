//
//  PanoAudioPanelView.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/4.
//

import UIKit

class PanoAudioMusicCell: UITableViewCell {
    
    var audioName: UILabel!
    var audioStateLabel: UILabel!
    var wrapView: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        wrapView = UIView()
        wrapView.layer.cornerRadius = 5
        wrapView.layer.masksToBounds = true
        self.contentView.addSubview(wrapView)
        
        audioName = UILabel()
        audioName.font = FontLittle
        audioName.textColor = DefaultTextColor
        audioName.text = "音乐1"
        wrapView.addSubview(audioName)
        
        audioStateLabel = UILabel()
        audioStateLabel.font = FontLittle
        audioStateLabel.textColor = DefaultTextColor
        audioStateLabel.text = "已暂停"
        wrapView.addSubview(audioStateLabel)
        
        wrapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: defaultMargin, bottom: 0, right: defaultMargin))
        }
        
        audioName.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(8)
        }
        
        audioStateLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(audioName.snp.right).offset(defaultMargin)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PanoAudioPanelView: PanoBaseView {
    
    var musicVolumeView: PanoAudioVolume!
    
    var effectVolumeView: PanoAudioVolume!
    
    var contentView: UIView!
    
    var coverView: UIView!
    
    var musicTitleLabel: UILabel!
    
    var effectTitleLabel: UILabel!
    
    var lineView: UIView!
    
    var musicView: UIStackView!
    
    var effectAudioView: UIStackView!
    
    var effectAudioView2: UIStackView!
    
    var dataSource = [String]()
    
    var dismissBlock : (() -> ())? = nil
    
    override func initViews() {
        
        coverView = UIView()
        coverView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        coverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        self.addSubview(coverView)
        
        contentView = UIView()
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 10;
        contentView.layer.masksToBounds = true
        self.addSubview(contentView)
        
        musicTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: PanoAppWidth, height: 50))
        musicTitleLabel.text = "背景音乐".localized()
        musicTitleLabel.textColor = DefaultTextColor
        musicTitleLabel.textAlignment = .center
        musicTitleLabel.font = FontLarger
        contentView.addSubview(musicTitleLabel)
        
        musicView = UIStackView()
        musicView.axis = .horizontal
        musicView.distribution = .fillEqually
        musicView.spacing = 30;
        contentView.addSubview(musicView)
        
        
        let audios = PanoPlayerService.service()?.audioNames;
        if let musicCount = audios?.count {
            for index in 0..<musicCount {
                let title = audios?[index] ?? ""
                let button = createMusicButton(title: title.localized(), image: nil)
                button.addTarget(self, action: #selector(chooseMusicAction(sender:)), for: .touchUpInside)
                musicView.addArrangedSubview(button)
            }
        }
        
        musicVolumeView = PanoAudioVolume()
        musicVolumeView.slider.maximumValue = 200;
        musicVolumeView.slider.value = 100;
        musicVolumeView.slider.addTarget(self, action: #selector(musicVolumeChanged(slider:)), for: .valueChanged)
        contentView.addSubview(musicVolumeView)
        
        lineView = UIView()
        lineView.backgroundColor = DefaultBorderColor
        contentView.addSubview(lineView)
        
        
        effectTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: PanoAppWidth, height: 50))
        effectTitleLabel.text = "声效".localized()
        effectTitleLabel.textColor = DefaultTextColor
        effectTitleLabel.textAlignment = .center
        effectTitleLabel.font = FontLarger
        contentView.addSubview(effectTitleLabel)
        
        effectAudioView = UIStackView()
        effectAudioView.axis = .horizontal
        effectAudioView.distribution = .fillEqually
        effectAudioView.spacing = 30;
        contentView.addSubview(effectAudioView)
        
        effectAudioView2 = UIStackView()
        effectAudioView2.axis = .horizontal
        effectAudioView2.distribution = .fillEqually
        effectAudioView2.spacing = 30;
        contentView.addSubview(effectAudioView2)
        
        let sounds = PanoPlayerService.service()?.soundNames;
        if let soundCount = sounds?.count {
            for index in 0..<3 {
                let title = sounds?[index] ?? ""
                let button = createMusicButton(title: title.localized(), image: nil)
                button.addTarget(self, action: #selector(chooseSoundEffectAction(sender:)), for: .touchUpInside)
                effectAudioView.addArrangedSubview(button)
            }
            
            for index in 3..<soundCount {
                let title = sounds?[index] ?? ""
                let button = createMusicButton(title: title.localized(), image: nil)
                button.addTarget(self, action: #selector(chooseSoundEffectAction(sender:)), for: .touchUpInside)
                effectAudioView2.addArrangedSubview(button)
            }
        }
        
        effectVolumeView = PanoAudioVolume()
        effectVolumeView.slider.addTarget(self, action: #selector(soundEffectVolumeChanged(slider:)), for: .valueChanged)
        effectVolumeView.slider.value = 120
        contentView.addSubview(effectVolumeView)
    }
    
    func createMusicButton(title: String, image: UIImage?) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal);
        button.setImage(image, for: .normal);
        button.setImage(image, for: .highlighted)
        button.setTitleColor(DefaultTextColor, for: .normal)
        button.setTitleColor(UIColor.white, for: .highlighted)
        button.setTitleColor(UIColor.white, for: .selected)
        button.setBackgroundImage(UIImage(color: UIColor.white), for: .normal)
        button.setBackgroundImage(UIImage(named: "home_bg_blue"), for: .selected)
        button.setBackgroundImage(UIImage(named: "home_bg_blue"), for: .highlighted)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.layer.borderColor = DefaultBorderColor.cgColor
        button.layer.borderWidth = 0.8;
        return button
    }
    
    @objc func chooseMusicAction(sender: UIButton) {
        guard let title = sender.titleLabel?.text?.localized() else { return  }
        let volume = musicVolumeView.slider.value
        if PanoPlayerService.service()?.activeAudioName == title {
            PanoPlayerService.service()?.stopAudioMixingTask(fileName: title)
        } else {
            PanoPlayerService.service()?.startAudioMixingTask(fileName: title, volume: Int32(volume))
        }
        self.updateStatus(title: PanoPlayerService.service()?.activeAudioName ?? "");
    }
    
    @objc func chooseSoundEffectAction(sender: UIButton) {
        guard let title = sender.titleLabel?.text?.localized() else { return  }
        let volume = effectVolumeView.slider.value
        PanoPlayerService.service()?.startSoundEffectTask(fileName: title, volume: Int32(volume))
    }
    
    override func initConstraints() {
        
        coverView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(contentView.snp.top)
        }
        contentView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(420)
            make.bottom.equalToSuperview().offset(5)
        }
        
        musicTitleLabel.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
        
        let insets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        musicView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(insets)
            make.top.equalTo(musicTitleLabel.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
      
        musicVolumeView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(musicView.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(UIEdgeInsets(top: 0, left: defaultMargin, bottom: 0, right: defaultMargin))
            make.top.equalTo(musicVolumeView.snp.bottom)
            make.height.equalTo(0.8)
        }
        
        effectTitleLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(lineView.snp.bottom)
            make.height.equalTo(60)
        }
        
        effectAudioView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(insets)
            make.top.equalTo(effectTitleLabel.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        effectAudioView2.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(insets)
            make.top.equalTo(effectAudioView.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        effectVolumeView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(effectAudioView2.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
    }
    
    func showInView(parentView: UIView) {
        if !(parentView.subviews.contains(self)) {
            parentView.addSubview(self)
        }
        self.alpha = 0.1;
        var frame = parentView.frame
        frame.origin.y = frame.size.height
        self.frame = frame
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        self.updateStatus(title: PanoPlayerService.service()?.activeAudioName ?? "")
    }
    
    func updateStatus(title: String) {
        for index in 0..<musicView.subviews.count {
            let view = musicView.subviews[index] as! UIButton
            if view.titleLabel?.text?.localized() == title {
                view.isSelected = true
            } else {
                view.isSelected = false
            }
        }
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0.1;
            self.frame = CGRect(x: 0, y: PanoAppHeight, width: PanoAppWidth, height: PanoAppHeight)
            self.removeFromSuperview()
            if (self.dismissBlock != nil) {
                self.dismissBlock!()
            }
        }
    }
    
    @objc func musicVolumeChanged(slider: UISlider) {
        PanoPlayerService.service()?.updateVolume(volume: Int32(slider.value))
    }
    
    @objc func soundEffectVolumeChanged(slider: UISlider) {
        
    }
}
