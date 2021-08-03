//
//  PanoClientConfig.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


/// 用户角色
typedef NS_ENUM(NSInteger, PanoUserMode) {
    PanoAndience = 0, // 观众
    PanoAnchor = 1 // 主播
};


@interface PanoClientConfig : NSObject
/// 用户名
@property (nonatomic, copy) NSString *userName;
/// 房间号码
@property (nonatomic, copy) NSString *roomId;
/// 用户ID
@property (nonatomic, assign) UInt64 userId;
/// 用户角色
@property (nonatomic, assign) PanoUserMode userMode;

@end

typedef void(^PanoCompletionBlock)(NSError *error);

NS_ASSUME_NONNULL_END
