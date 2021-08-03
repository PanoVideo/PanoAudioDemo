//
//  PanoMicInfo.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/16.
//

#import "PanoMicInfo.h"
#import "PanoClientService.h"

@implementation PanoMicInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.status = PanoMicNone;
        self.userId = 0;
        self.order = -1;
    }
    return self;
}
- (instancetype)initWithStatus:(PanoMicStatus)status
                        userId:(UInt64)userId
                         order:(NSInteger)order {
    self = [super init];
    if (self) {
        self.status = status;
        self.userId = userId;
        self.order = order;
    }
    return self;
}

- (instancetype)initWithMicInfo:(PanoMicInfo *)info {
    return [self initWithStatus:info.status userId:info.userId order:info.order];
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    id userId = dict[@"userId"];
    id status = dict[@"status"];
    id order = dict[@"order"];
    if (!userId || !status || !order) {
        return nil;
    }
    self.userId = [userId integerValue];
    self.status = [status integerValue];
    self.order = [order integerValue];
    return self;
}

- (PanoUserInfo *)user {
    return [PanoClientService.service.userService findUserWithId:_userId];
}

- (BOOL)isOnline {
    return self.status == PanoMicFinished || self.status == PanoMicFinishedMuted;
}

- (NSDictionary *)toDictionary {
    return @{
        @"status" : @(self.status),
        @"userId" : @(self.userId),
        @"order" : @(self.order)
    };
}

- (BOOL)isEqual:(id)object {
    return self.order == ((PanoMicInfo *)object).order;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ : %@", [super description], [self toDictionary]];
}

- (id)copyWithZone:(NSZone *)zone {
    PanoMicInfo *micInfo = [PanoMicInfo allocWithZone:zone];
    micInfo.status = _status;
    micInfo.userId = _userId;
    micInfo.order = _order;
    return micInfo;
}


@end

