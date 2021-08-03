//
//  PanoMessageDefine.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/16.
//

#import <Foundation/Foundation.h>
#import "PanoMicInfo.h"
#import "PanoMessageEnum.h"


@interface PanoAbstractMessage : NSObject

@property (nonatomic, assign) PanoMsgType cmd;
@property (nonatomic, copy)   NSString *version;
@property (nonatomic, assign) UInt64 timestamp;
@property (nonatomic, strong) id data;

- (instancetype)initWithCmd:(PanoMsgType)cmd
                    version:(NSString *)version
                       data:(id)data;

- (instancetype)initWithDict:(NSDictionary *)dict;

- (NSDictionary *)toDictionary;

@end


@class PanoMicInfo;

@interface PanoMicMessage : PanoAbstractMessage

@property (nonatomic, assign) PanoCmdReason reason;

- (instancetype)initWithCmd:(PanoMsgType)cmd
                       data:(NSArray<PanoMicInfo *> *)data
                     reason:(PanoCmdReason)reason;

@end

@interface PanoCmdMessage : PanoAbstractMessage

- (instancetype)initWithCmd:(PanoMsgType)cmd
                       data:(NSDictionary<NSString *, id> *)data;

@end


