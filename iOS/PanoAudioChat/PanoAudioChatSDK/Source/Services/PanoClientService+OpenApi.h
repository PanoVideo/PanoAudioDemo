//
//  PanoClientService+OpenApi.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/15.
//

#import "PanoClientService.h"
#import "PanoSignalInterface.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PanoAudioChatSDKInterface <NSObject>

- (void)joinWithConfigWithCompletion:(PanoCompletionBlock)block;

- (void)leaveAudioRoom;

- (UIViewController *)settingViewController;

@end

@interface PanoClientService (OpenApi) <PanoAudioChatSDKInterface, PanoSignalInterface>

@end

NS_ASSUME_NONNULL_END
