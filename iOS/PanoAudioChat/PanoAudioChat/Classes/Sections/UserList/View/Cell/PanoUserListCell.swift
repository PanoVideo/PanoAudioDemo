//
//  PanoUserListCell.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/2.
//

import UIKit

class PanoUserListCell: UITableViewCell {

    var avator: UIImageView!
    
    var nameLabel: UILabel!
    
    var chooseButton: UIButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        chooseButton = UIButton(type: .custom)
//        chooseButton.addTarget(self, action: #selector(chooseAction), for: .touchUpInside)
//        chooseButton.setImage(UIImage(named: "userList_unselect"), for: .normal)
//        chooseButton.setImage(UIImage(named: "userList_select"), for: .selected)
//        chooseButton.imageView?.contentMode = .scaleAspectFit
//        self.contentView.addSubview(chooseButton)
        
        nameLabel = UILabel()
        nameLabel.font = FontLarger
        self.contentView.addSubview(nameLabel)
        
        avator = UIImageView()
        avator.image = UIImage(named: "room_avator")
        self.contentView.addSubview(avator)
        
        
//        chooseButton.snp.makeConstraints { (make) in
//            make.size.equalTo(CGSize(width: 30, height: 30))
//            make.centerY.equalToSuperview()
//            make.left.equalToSuperview().offset(defaultMargin)
//        }
        
        avator.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 35, height: 35))
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(defaultMargin)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.equalTo(avator.snp.right).offset(defaultMargin)
            make.height.equalTo(30)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    @objc func chooseAction() {
//        self.chooseButton.isSelected = !self.chooseButton.isSelected;
//    }
    
}
