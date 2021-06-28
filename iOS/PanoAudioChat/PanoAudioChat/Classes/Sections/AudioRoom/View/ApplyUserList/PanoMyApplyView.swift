//
//  PanoMyApplyView.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/3.
//

import UIKit

class PanoMyApplyView: PanoBaseView {

    var nameLabel : UILabel!
    
    var cancelBtn : UIButton!
    
    var cancelBlock: (() -> Void)!
    
    override func initViews() {
        
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = true;
        
        self.backgroundColor = UIColor.white
        nameLabel = UILabel()
        nameLabel.font = FontMedium
        nameLabel.textColor = DefaultTextColor
        nameLabel.text = NSLocalizedString("已申请上麦，等候通过···", comment: "")
        nameLabel.sizeToFit()
        self.addSubview(nameLabel)
        
        cancelBtn = UIButton()
        cancelBtn.setTitle(NSLocalizedString("取消", comment: ""), for: .normal)
        cancelBtn.setTitleColor(UIColor("#69B4F9"), for: .normal)
        cancelBtn.setTitleColor(UIColor("#69B4F9"), for: .highlighted)
        cancelBtn.addTarget(self, action: #selector(cancelApplyChat), for: .touchUpInside)
        cancelBtn.sizeToFit()
        self.addSubview(cancelBtn)
    }
    
    override func initConstraints() {
        nameLabel.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 0))
            make.right.equalTo(cancelBtn.snp.left).offset(-defaultMargin)
        }
        cancelBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-defaultMargin)
            make.centerY.equalTo(nameLabel)
        }
    }
    
    func showInView(view: UIView){
        view.addSubview(self)
        let viewHeight = (PanoIsIphoneX() ? 44 : 20) + 40
        self.snp.remakeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.snp.top)
            make.height.equalTo(viewHeight)
        }
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(translationX: 0, y: CGFloat(viewHeight))
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform.identity
        } completion: { (flag) in
            self.removeFromSuperview()
        }
    }
    
    @objc func cancelApplyChat() {
        cancelBlock();
    }
}
