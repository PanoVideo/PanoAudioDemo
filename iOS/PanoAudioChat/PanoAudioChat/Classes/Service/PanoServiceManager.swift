//
//  PanoServiceManager.swift
//  PanoAudioRoom
//
//  Created by wenhua.zhang on 2020/10/28.
//

import Foundation

public class PanoServiceManager {

    public enum PanoServiceType : Int {
        case client = 0;
        case audio = 1;
        case user = 2;
        case chat = 3;
        case player = 4
    }

    private static var g_services = [PanoServiceType: PanoBaseService]()
    private static let lock = NSLock.init()

    static func service(type: PanoServiceType) -> PanoBaseService? {
        lock.lock()
        if g_services[type] == nil {
            switch type {
            case .client:
                g_services[type] = PanoClientService()
                break
            case .audio:
                g_services[type] = PanoAudioService()
                break
            case .user:
                g_services[type] = PanoUserService()
                break
            case .chat:
                g_services[type] = PanoChatService()
                break
            case .player:
                g_services[type] = PanoPlayerService()
                break
            }
        }
        let result = g_services[type]
        lock.unlock()
        return result
    }

    static func uninit() {
        print("\(NSDate()) uninit")
        lock.lock()
        for service in g_services.values {
            service.uninit()
        }
        g_services.removeAll()
        lock.unlock()
    }
    
}
