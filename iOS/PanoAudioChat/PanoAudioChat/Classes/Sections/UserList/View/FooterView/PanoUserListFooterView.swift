//
//  PanoUserListFooterView.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/2.
//

import UIKit

protocol PanoUserListFooterViewDelegate: NSObjectProtocol {
    
    func dismiss();
    
    func inviteUser();
}

class PanoUserListFooterView: PanoBaseView {

    var selectAllBtn: UIButton!
    var finishBtn: UIButton!
    var cancelBtn: UIButton!
    
    var lineView: UIView!
    
    weak var delegate: PanoUserListFooterViewDelegate?
    
    override func initViews() {
                
        finishBtn = UIButton()
        finishBtn.setTitle(NSLocalizedString("完成", comment: ""), for: .normal)
        finishBtn.titleLabel?.textColor = UIColor.white
        finishBtn.setBackgroundImage(UIImage(named: "home_bg_blue"), for: .normal)
        finishBtn.setBackgroundImage(UIImage(named: "home_bg_blue"), for: .highlighted)
        finishBtn.addTarget(self, action: #selector(selectFinishAction), for: .touchUpInside)
        finishBtn.layer.masksToBounds = true
        finishBtn.layer.cornerRadius = 15.0
        self.addSubview(finishBtn)
        
        cancelBtn = UIButton()
        cancelBtn.setTitle(NSLocalizedString("取消", comment: ""), for: .normal)
        cancelBtn.setTitleColor(DefaultTextColor, for: .normal)
        cancelBtn.setTitleColor(DefaultTextColor, for: .highlighted)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        self.addSubview(cancelBtn)
        
        
        lineView = UIView()
        lineView.backgroundColor = DefaultBorderColor
        self.addSubview(lineView)
    }
    
    override func initConstraints() {
        lineView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview().inset(UIEdgeInsets(top: 0, left: defaultMargin, bottom: 0, right: defaultMargin))
            make.height.equalTo(0.8);
        }
        
        cancelBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-defaultMargin)
            make.height.equalTo(30)
            make.width.equalTo(84)
        }
        
        finishBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(cancelBtn.snp.left).offset(-defaultMargin)
            make.height.equalTo(cancelBtn)
            make.width.equalTo(cancelBtn)
        }
    }
    
    @objc func selectFinishAction() {
        delegate?.inviteUser()
    }
    
    @objc func cancelAction() {
        delegate?.dismiss()
    }
}
