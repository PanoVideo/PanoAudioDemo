//
//  PanoBaseService.swift
//  PanoAudioRoom
//
//  Created by wenhua.zhang on 2020/10/28.
//

import Foundation


class PanoBaseService : NSObject  {
    @objc open class func service() -> PanoBaseService? {
        return nil
    }
    
    override init() {
        super.init()
        print(self, "init")
    }
    deinit {
        print(self, "deinit")
    }
    func uninit() {
        
    }
}

