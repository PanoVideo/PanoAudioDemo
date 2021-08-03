//
//  PanoUserInfo.h
//  PanoVideoCall
//
//  Created by pano on 2020/9/28.
//  Copyright © 2020 Pano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PanoUserAudioStatus) {
    PanoUserAudio_None = 1, ///<  未连语音
    PanoUserAudio_Unmute, ///<  语音是打开的状态
    PanoUserAudio_Mute, ///< 语音是静音状态
};

/// 用户信息
@interface PanoUserInfo : NSObject <NSCopying>

@property (assign, nonatomic, readonly) UInt64 userId;

@property (copy, nonatomic, readonly) NSString * _Nullable userName;

@property (assign, nonatomic) PanoUserAudioStatus audioStatus;

- (instancetype)initWithId:(UInt64)userId name:(NSString * _Nullable)userName;

- (instancetype)init NS_UNAVAILABLE;

@end


@interface PanoUserInfo (Add)

- (BOOL)isActiving;

- (UIImage *)avatorImage;

@end

NS_ASSUME_NONNULL_END
