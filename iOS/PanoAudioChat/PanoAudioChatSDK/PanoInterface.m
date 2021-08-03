//
//  PanoInterface.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/21.
//

#import "PanoInterface.h"
#import "PanoClientService+OpenApi.h"
#import "PanoClientService+App.h"
#import "PanoAudioRoomController.h"

@implementation PanoInterface

+ (void)start {
    [PanoClientService.service loadPreferences];
}

+ (UIViewController *)instantiateViewControllerWithConfig:(PanoClientConfig *)config {
    [PanoClientService.service startWithConfig:config];
    PanoAudioRoomController *vc = [[PanoAudioRoomController alloc] init];
    return vc;
}

+ (void)leave {
    [PanoClientService.service leaveAudioRoom];
}

+ (UIViewController *)settingViewController {
    return [PanoClientService.service settingViewController];
}
@end
