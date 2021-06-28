//
//  PanoUserListHeaderView.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/2.
//

import UIKit

class PanoUserListHeaderView: PanoBaseView {

    var headerLabel: UILabel!
    var lineView: UIView!
    
    override func initViews() {
        headerLabel = UILabel()
        headerLabel.textColor = DefaultTextColor
        headerLabel.textAlignment = .center
        headerLabel.font = FontLarger
        headerLabel.text = "􏱌􏱍􏱎􏱏选择成员"
        self.addSubview(headerLabel)
        
        lineView = UIView()
        lineView.backgroundColor = DefaultBorderColor
        self.addSubview(lineView)
    }
    
    override func initConstraints() {
        headerLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(55.5);
        }
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(UIEdgeInsets(top: 0, left: defaultMargin, bottom: 0, right: defaultMargin))
            make.height.equalTo(0.8);
            make.bottom.equalToSuperview().offset(-0.8);
        }
    }
}
