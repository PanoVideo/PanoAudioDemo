//
//  PanoMessageDefine.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/16.
//

#import "PanoMessageDefine.h"

NSString *PanoAudioChatMsg = @"pano_audio_chat";

NSString *PanoMsgUserId = @"msg_user_id";

NSString *PanoMsgChatContent = @"msg_chat_content";

// 申请上麦或者邀请上麦消息的超时时间
UInt64 PanoMsgExpireInterval = 30;

// MARK: key: PropertyKey, value: [String : Any]
NSString *PanoAllMicKey = @"msg_all_mic_info_key";

@implementation PanoAbstractMessage

- (instancetype)initWithCmd:(PanoMsgType)cmd
                    version:(NSString *)version
                       data:(id)data {
    self = [super init];
    if (self) {
        self.cmd = cmd;
        self.version = version ? version : @"1";
        self.timestamp = [[NSDate new] timeIntervalSince1970] * 1000;
        self.data = data;
    }
    return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        NSInteger cmd = [dict[@"cmd"] integerValue];
        NSString *ver = dict[@"version"];
        UInt64 ts = [dict[@"timestamp"] integerValue];
        self.cmd = cmd;
        self.version = ver;
        self.timestamp = ts;
        self.data = dict[@"data"];
    }
    return self;
}

- (NSDictionary *)toDictionary {
    return @{
        @"cmd" : @(self.cmd),
        @"version" : self.version,
        @"timestamp" : @(self.timestamp)
    };
}

@end

@implementation PanoMicMessage

- (instancetype)initWithCmd:(PanoMsgType)cmd
                       data:(NSArray<PanoMicInfo *> *)data
                     reason:(PanoCmdReason)reason {
    self = [super initWithCmd:cmd version:nil data:data];
    self.reason = reason;
    return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    id reason = dict[@"reason"];
    NSArray *arr = dict[@"data"];
    if (!reason || !arr || ![arr isKindOfClass:[NSArray class]]) {
        return nil;
    }
    self = [super initWithDict:dict];
    NSMutableArray *tempData = [NSMutableArray array];
    for (NSDictionary * item in arr) {
        PanoMicInfo *info = [[PanoMicInfo alloc] initWithDict:item];
        if (info) {
            info.timestamp = self.timestamp;
            [tempData addObject:info];
        }
    }
    self.data = tempData;
    self.reason = [reason integerValue];
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    NSMutableArray *mArray = [NSMutableArray array];
    for (PanoMicInfo *mic in self.data) {
        [mArray addObject:[mic toDictionary]];
    }
    NSDictionary *newInfo = @{ @"data": mArray, @"reason": @(self.reason) };
    [info addEntriesFromDictionary:newInfo];
    NSLog(@"info-> %@", info);
    return info;
}

@end

@implementation PanoCmdMessage

- (instancetype)initWithCmd:(PanoMsgType)cmd
                       data:(NSDictionary<NSString *,id> *)data {
    return [super initWithCmd:cmd version:nil data:data];
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    return [super initWithDict:dict];
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    if (self.data != nil) {
        [info addEntriesFromDictionary:@{@"data" : self.data}];
    }
    return info;
}

@end
