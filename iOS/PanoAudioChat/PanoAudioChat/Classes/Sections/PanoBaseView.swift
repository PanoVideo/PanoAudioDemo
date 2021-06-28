//
//  PanoBaseView.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import UIKit
import SnapKit
import UIColor_Hex_Swift
import Localize_Swift

class PanoBaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        initConstraints()
    }
    
    func initViews() {
        
    }
    
    func initConstraints() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(self, "deinit")
    }
    
}
