//
//  AppDelegate.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        PanoClientService.loadPreferences()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let vc = PanoHomeViewController()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        return true
    }
}
