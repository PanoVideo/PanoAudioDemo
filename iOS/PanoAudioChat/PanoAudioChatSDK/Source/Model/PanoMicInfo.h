//
//  PanoMicInfo.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/16.
//

#import <Foundation/Foundation.h>
#import "PanoMessageDefine.h"
#import "PanoMessageEnum.h"
#import "PanoUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface PanoMicInfo : NSObject <NSCopying>

@property (nonatomic, assign) PanoMicStatus status;

@property (nonatomic, assign) UInt64 userId;

@property (nonatomic, assign) NSInteger order;

@property (nonatomic, assign) UInt64 timestamp;

- (instancetype)initWithStatus:(PanoMicStatus)status
                        userId:(UInt64)userId
                         order:(NSInteger)order;

- (instancetype)initWithMicInfo:(PanoMicInfo *)info;

- (instancetype)initWithDict:(NSDictionary *)dict;

- (BOOL)isOnline;

- (PanoUserInfo *)user;

- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
