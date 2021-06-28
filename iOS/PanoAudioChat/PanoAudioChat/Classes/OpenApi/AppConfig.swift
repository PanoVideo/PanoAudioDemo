//
//  AppConfig.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2021/6/11.
//

import Foundation

/**
 1. 请输入AppID，PanoServerURL
 2. 参考 https://console.pano.video/#/user/login
 */
@objc final class AppConfig: NSObject {
    
    static let PanoAppID: String = <#T##PanoAppID: String##String#>;
    
    static var PanoRtcServerURL: String = "api.pano.video";
}
