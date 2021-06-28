//
//  PanoChatTextCell.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/4.
//

import UIKit

class PanoChatTextCell: UITableViewCell {
    
    var contentLabel: UILabel!
    var wrapView: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        wrapView = UIView()
        wrapView.layer.cornerRadius = 5
        wrapView.layer.masksToBounds = true
        self.contentView.addSubview(wrapView)
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    
        contentLabel = UILabel()
        contentLabel.font = FontMedium
        contentLabel.textColor = UIColor.white
        contentLabel.numberOfLines = 0
        wrapView.addSubview(contentLabel)
        
        wrapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: defaultMargin, bottom: 0, right: defaultMargin))
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 8 , bottom: 8, right: 8))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


