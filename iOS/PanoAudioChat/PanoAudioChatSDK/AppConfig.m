//
//  AppConfig.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/21.
//

#import "AppConfig.h"

/**
 1. 请输入PanoAppID，PanoServerURL
 2. 参考 https://console.pano.video/#/user/login
 */

static NSString *PanoAppID = <#T##PanoAppID: String##String#>;

static NSString *PanoRtcServer = @"api.pano.video";

@implementation AppConfig

+ (NSString *)appID {
    return PanoAppID;
}

+ (NSString *)rtcServerURL {
    return PanoRtcServer;
}

@end
