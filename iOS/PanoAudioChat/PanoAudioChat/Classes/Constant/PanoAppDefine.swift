//
//  PanoAppDefine.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import Foundation
import UIColor_Hex_Swift

let defaultMargin: CGFloat = 15.0;

let PanoAppWidth = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)

let PanoAppHeight = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)


func PanoIsIphoneX() -> Bool {
    if #available(iOS 11.0, *) {
        let safeInsets = UIApplication.shared.keyWindow?.safeAreaInsets
        return safeInsets!.bottom  > 0
    } else {
        return false
    }
}

func PanoIsPhone() -> Bool {
    UI_USER_INTERFACE_IDIOM() == .phone
}
func PanoStatusBarHeight() -> CGFloat {
    return PanoIsIphoneX() ? 44 : 20;
}

public enum PanoFontSize : CGFloat {
    
    case min = 10
    
    case little = 12
    
    case medium = 16
    
    case larger = 18
    
    case max = 22
}

let FontMax = UIFont.systemFont(ofSize: PanoFontSize.max.rawValue)

let FontLarger = UIFont.systemFont(ofSize: PanoFontSize.larger.rawValue)

let FontMedium = UIFont.systemFont(ofSize: PanoFontSize.medium.rawValue)

let FontLittle = UIFont.systemFont(ofSize: PanoFontSize.little.rawValue)

let FontMin = UIFont.systemFont(ofSize: PanoFontSize.min.rawValue)


let DefaultTextColor = UIColor("#333333")


let DefaultBorderColor = UIColor("#EEEEEE")

let DefaultViewHeight = 40

let DefaultCornerRadius : CGFloat = CGFloat(DefaultViewHeight / 2)


let ButtonHeight = 44

let ButtonCornerRadius : CGFloat = CGFloat(ButtonHeight / 2)


struct  AppInfo {
    
    static let infoDictionary = Bundle.main.infoDictionary
    
//    static let appDisplayName: String = Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String //App 名称
    
    static let productName : String = Bundle.main.infoDictionary!["CFBundleName"] as! String
    
    static let bundleIdentifier:String = Bundle.main.bundleIdentifier! // Bundle Identifier
    
    static let appVersion:String = Bundle.main.infoDictionary! ["CFBundleShortVersionString"] as! String// App 版本号
    
    static let buildVersion : String = Bundle.main.infoDictionary! ["CFBundleVersion"] as! String //Bulid 版本号
    
    static let iOSVersion:String = UIDevice.current.systemVersion //ios 版本
    
//    static let identifierNumber = UIDevice.current.identifierForVendor //设备 udid
    
    static let systemName = UIDevice.current.systemName //设备名称
    
    static let model = UIDevice.current.model // 设备型号
    
    static let localizedModel = UIDevice.current.localizedModel  //设备区域化型号

}
