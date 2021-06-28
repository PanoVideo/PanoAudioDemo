//
//  ApplyUserListCell.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/3.
//

import UIKit


typealias PanoApplyButtonClosure = (() -> Void)
class PanoApplyUserListCell : UITableViewCell {

    var acceptBtn : UIButton!
    var rejectBtn : UIButton!
    var nameLabel : UILabel!
    var lineView : UIView!
    var acceptBlock : PanoApplyButtonClosure!
    var rejectBlock : PanoApplyButtonClosure!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        
        lineView = UIView()
        lineView.backgroundColor = DefaultBorderColor
        self.contentView.addSubview(lineView)
        
        nameLabel = UILabel()
        nameLabel.font = FontMedium
        nameLabel.textColor = DefaultTextColor
        self.contentView.addSubview(nameLabel)
        
        acceptBtn = UIButton()
        acceptBtn.setTitle(NSLocalizedString("允许", comment: ""), for: .normal)
        acceptBtn.titleLabel?.textColor = UIColor.white
        acceptBtn.setBackgroundImage(UIImage(named: "home_bg_blue"), for: .normal)
        acceptBtn.setBackgroundImage(UIImage(named: "home_bg_blue"), for: .highlighted)
        acceptBtn.addTarget(self, action: #selector(accept(sender:)), for: .touchUpInside)
        acceptBtn.layer.masksToBounds = true
        acceptBtn.layer.cornerRadius = 15.0
        self.contentView.addSubview(acceptBtn)
        
        rejectBtn = UIButton()
        rejectBtn.setTitle(NSLocalizedString("拒绝", comment: ""), for: .normal)
        rejectBtn.setTitleColor(DefaultTextColor, for: .normal)
        rejectBtn.setTitleColor(DefaultTextColor, for: .highlighted)
        rejectBtn.addTarget(self, action: #selector(reject(sender:)), for: .touchUpInside)
        self.contentView.addSubview(rejectBtn)
        
        lineView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0.8, right: 0))
            make.height.equalTo(0.8);
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(defaultMargin)
            make.right.equalTo(rejectBtn.snp.left).offset(-defaultMargin)
        }
        
        acceptBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-defaultMargin)
            make.height.equalTo(30)
            make.width.equalTo(84)
        }
        
        rejectBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(acceptBtn.snp.left).offset(-defaultMargin)
            make.height.equalTo(acceptBtn)
            make.width.equalTo(acceptBtn)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func accept(sender: UIButton!) {
        acceptBlock();
    }

    @objc func reject(sender: UIButton!) {
        rejectBlock();
    }
}
