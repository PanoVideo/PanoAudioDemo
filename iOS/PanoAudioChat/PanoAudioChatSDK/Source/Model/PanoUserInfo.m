//
//  PanoUserInfo.m
//  PanoVideoCall
//
//  Created by pano on 2020/9/28.
//  Copyright © 2020 Pano. All rights reserved.
//

#import "PanoUserInfo.h"

@implementation PanoUserInfo

- (instancetype)initWithId:(UInt64)userId name:(NSString * _Nullable)userName {
    self = [super init];
    if (nil != self) {
        _userId = userId;
        _userName = userName;
        _audioStatus = PanoUserAudio_None;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[PanoUserInfo class]]) {
        return false;
    }
    return self.userId == ((PanoUserInfo *)object).userId;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ _userId: %lld _userName: %@ _audioStatus: %ld",[super description] ,_userId, _userName, (long)_audioStatus];
}

- (id)copyWithZone:(NSZone *)zone {
    PanoUserInfo *info = [[PanoUserInfo alloc] initWithId:_userId name:_userName];
    info.audioStatus = _audioStatus;
    return info;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"forUndefinedKey: %@", key);
}

@end
