//
//  PanoNaviTitleView.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/30.
//

import UIKit

class PanoNaviTitleView  {

    var titleView: UILabel!
    var title: String!
    var subTitle: String!
    
    init(title: String, subTitle: String) {
        self.title = title
        self.subTitle = subTitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func naviTitleView() -> UIView {
        
        titleView = UILabel()
        titleView.textAlignment = .center
        titleView.numberOfLines = 0
        let whiteColor = UIColor.white
        let attrStr =  NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor : whiteColor, NSAttributedString.Key.font : FontLarger
                                                                 
        ])
        
        attrStr.append(NSAttributedString(string: "\n"))
        
        let subStr = NSAttributedString(string: subTitle, attributes: [NSAttributedString.Key.foregroundColor : whiteColor, NSAttributedString.Key.font : FontMin
        ])
        
        attrStr.append(subStr)
        
        titleView.attributedText = attrStr
        
        return titleView
    }
}
