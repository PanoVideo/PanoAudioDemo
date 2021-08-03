//
//  PanoInterface.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/21.
//

#import <Foundation/Foundation.h>
#import "PanoClientConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface PanoInterface : NSObject

+ (void)start;

+ (void)leave;

+ (UIViewController *)instantiateViewControllerWithConfig:(PanoClientConfig *)config;

+ (UIViewController *)settingViewController;

@end

NS_ASSUME_NONNULL_END
