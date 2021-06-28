//
//  PanoTextField.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import UIKit

class PanoTextField: PanoBaseView {
    
    var leftLabel : UILabel!
    
    var textfiled: UITextField!
    
    var contentView: UIView!
    
    override func initViews() {
        
        contentView = UIView()
        self.addSubview(contentView)
        
        leftLabel = UILabel()
        leftLabel.textColor = DefaultTextColor
        leftLabel.textAlignment = .left
        leftLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(leftLabel)
        
        textfiled = UITextField()
        textfiled.layer.cornerRadius = DefaultCornerRadius
        textfiled.layer.masksToBounds = true
        textfiled.layer.borderColor = DefaultBorderColor.cgColor
        textfiled.layer.borderWidth = 1
        textfiled.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: DefaultViewHeight))
        textfiled.leftViewMode = .always
        contentView.addSubview(textfiled)
    }
    
    override func initConstraints() {
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        leftLabel.snp.makeConstraints { (make) in
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(60)
            make.right.equalTo(textfiled.snp.left).offset(-20)
        }
        
        textfiled.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.height.equalTo(DefaultViewHeight)
        }
    }
}
