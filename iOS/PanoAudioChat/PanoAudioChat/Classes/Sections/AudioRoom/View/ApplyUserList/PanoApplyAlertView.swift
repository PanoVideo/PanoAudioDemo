//
//  PanoApplyAlertView.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/3.
//

import UIKit

class PanoApplyAlertView: PanoBaseView {
    
    var countBtn: UIButton!
    var contentView: UIView!
    var countLabel: UILabel!
    override func initViews() {
        
        self.backgroundColor = UIColor.clear
        
//        contentView = UIView(frame: CGRect(x: 0, y: 0, width: PanoAppWidth, height: 20))
//        contentView.backgroundColor = UIColor.white
//        self.addSubview(contentView)
        
        countBtn = UIButton()
        let image = UIImage(color: UIColor("#EC2C2C"))
        countBtn.setBackgroundImage(image, for: .normal)
        countBtn.setBackgroundImage(image, for: .selected)
        countBtn.layer.masksToBounds = true
        countBtn.layer.cornerRadius = 12.5;
        
        countLabel = UILabel()
        countLabel.textColor = UIColor.white
        countLabel.textAlignment = .center
        countBtn.addSubview(countLabel)
        
        self.addSubview(countBtn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 15)
    }
        
    override func initConstraints() {
//        contentView.snp.makeConstraints { (make) in
//            make.left.right.top.equalToSuperview()
//            make.height.equalTo(20);
//        }
//        
        countBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 25, height: 25))
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func updateAlertView(pushed: Bool) {
//        if pushed {
//            contentView.snp.makeConstraints { (make) in
//                make.top.left.right.equalToSuperview()
//                make.height.equalTo(20);
//            }
//        } else {
//            contentView.snp.makeConstraints { (make) in
//                make.top.centerX.equalToSuperview()
//                make.height.equalTo(20);
//                make.width.equalTo(184)
//            }
//        }
    }
}
