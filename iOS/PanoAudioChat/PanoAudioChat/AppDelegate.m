//
//  AppDelegate.m
//  PanoAudioChat
//
//  Created by pano on 2021/7/21.
//

#import "AppDelegate.h"
#import "PanoInterface.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [PanoInterface start];
    return YES;
}

@end
