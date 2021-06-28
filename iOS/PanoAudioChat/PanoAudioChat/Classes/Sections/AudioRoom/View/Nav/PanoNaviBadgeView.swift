//
//  PanoNaviBadgeView.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/6.
//

import UIKit

class PanoNaviBadgeView: PanoBaseView {
    
    var button: UIButton!
    var badgeLabel: UILabel!
    var buttonImage: UIImage?
    var block: (() -> Void)!
    
    init(image: UIImage?, operationBlock: @escaping () -> Void ) {
        buttonImage = image
        self.block = operationBlock
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initViews() {
        button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(buttonImage, for: .normal)
        button.setImage(buttonImage, for: .highlighted)
        button.addTarget(self, action: #selector(clickAction), for: .touchUpInside)
        self.addSubview(button)
        
        badgeLabel = UILabel()
        badgeLabel.textColor = UIColor.white
        badgeLabel.backgroundColor = UIColor.red
        badgeLabel.font = FontLittle
        badgeLabel.layer.cornerRadius = 7.5
        badgeLabel.layer.masksToBounds = true
        badgeLabel.textAlignment = .center
        self.addSubview(badgeLabel)
    }
    
    override func initConstraints() {
        button.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        badgeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(button).offset(10.6)
            make.centerY.equalTo(button).offset(-10.6)
            make.size.equalTo(CGSize(width: 15, height: 15))
        }
    }
    
    @objc func clickAction() {
        self.block()
    }
}
