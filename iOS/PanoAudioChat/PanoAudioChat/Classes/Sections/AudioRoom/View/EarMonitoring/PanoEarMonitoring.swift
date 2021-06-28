//
//  PanoEarMonitoring.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/4.
//

import UIKit

class PanoEarMonitoring: PanoBaseView {

    var mySwitch: UISwitch! = nil
    var slider : UISlider!
    var titleLabel: UILabel!
    var cancelBtn: UIButton!
    var switchCell: UITableViewCell!
    var sliderCell: UITableViewCell!
    var contentView: UIView!
    var coverView: UIView!
    override func initViews() {
    
        coverView = UIView()
        coverView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        coverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        self.addSubview(coverView)
        
        contentView = UIView()
        contentView.layer.cornerRadius = 10;
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor("#EEEFF2")
        self.addSubview(contentView)
        
        titleLabel = UILabel()
        titleLabel.backgroundColor = UIColor.white
        titleLabel.font = FontLarger
        titleLabel.textColor = DefaultTextColor
        titleLabel.text = "耳返设置".localized()
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        
        mySwitch = UISwitch()
        mySwitch.isOn = false
        mySwitch.addTarget(self, action: #selector(earMonitoring(mySwitch:)), for: .valueChanged)
        switchCell = UITableViewCell(style: .default, reuseIdentifier: "c1")
        switchCell.textLabel?.text = "耳返".localized();
        switchCell.accessoryType = .disclosureIndicator
        switchCell.accessoryView = mySwitch
        switchCell.backgroundColor = UIColor.white
        contentView.addSubview(switchCell)
        
        slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 255
        slider.addTarget(self, action: #selector(volumeChanged(slider:)), for: .touchUpInside)
        sliderCell = UITableViewCell(style: .default, reuseIdentifier: "c2")
        sliderCell.accessoryType = .disclosureIndicator
        sliderCell.textLabel?.text = "耳返音量大小".localized();
        sliderCell.accessoryView = slider
        let oldFrame = sliderCell.accessoryView!.frame
        let x = sliderCell.textLabel!.frame.origin.x + sliderCell.textLabel!.frame.size.width
        sliderCell.accessoryView?.frame = CGRect(x: x + 30, y: oldFrame.origin.y, width: 250, height: oldFrame.size.height)
        slider.value = 100
        sliderCell.backgroundColor = UIColor.white
        contentView.addSubview(sliderCell)
        
        cancelBtn = UIButton(type: .custom)
        cancelBtn.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        cancelBtn.setTitle("取消".localized(), for: .normal);
        cancelBtn.setTitleColor(DefaultTextColor, for: .normal)
        cancelBtn.backgroundColor = UIColor.white
        contentView.addSubview(cancelBtn)
        
    }
    
    override func initConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(58)
        }
        switchCell.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(58)
        }
        
        sliderCell.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(switchCell.snp.bottom)
            make.height.equalTo(58)
        }
        
        cancelBtn.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(58)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(58 * 4 + 20)
        }
        coverView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(contentView.snp.top)
        }
    }
    
    @objc func earMonitoring(mySwitch: UISwitch) {
        if mySwitch.isOn && !PanoAudioService.hasHeadphonesDevice() {
            self.makeToast("请插上耳机体验".localized(), duration: 3, position: .center)
            mySwitch.isOn = false;
            return;
        }
        PanoAudioService.service()?.enableAudioEarMonitoring(enable: mySwitch.isOn)
    }
    
    @objc func volumeChanged(slider: UISlider)  {
        print("setAudioDeviceVolume", slider.value)
        PanoAudioService.service()?.setAudioDeviceVolume(volume: UInt32(slider.value));
    }
    
    @objc func dismiss() {
        self.removeFromSuperview()
    }
    
    func showInView(parentView: UIView) {
        if !(parentView.subviews.contains(self)) {
            parentView.addSubview(self)
        }
        self.alpha = 0.1
        self.frame = CGRect(x: 0, y: PanoAppHeight, width: parentView.frame.size.width, height: parentView.frame.size.height)
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
}
