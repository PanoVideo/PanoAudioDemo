//
//  PanoAudioVolume.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/4.
//

import UIKit

class PanoAudioVolume: PanoBaseView {
    
    var icon: UIImageView!
    open var slider: UISlider!
    
    override func initViews() {
        icon = UIImageView(image: UIImage(named: "room_loudspeaker_black"))
        self.addSubview(icon)
        
        slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 200
        slider.value = 50
        self.addSubview(slider)
    }
    
    override func initConstraints() {
        
        icon.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.centerY.equalToSuperview()
        }
        
        slider.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(icon.snp.right).offset(defaultMargin)
            make.right.equalToSuperview().offset(-30)
        }
    }
}
