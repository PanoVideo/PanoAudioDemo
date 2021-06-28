//
//  PanoBaseNavigationController.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import UIKit

class PanoBaseNavigationController: UINavigationController {
    
    override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}
