//
//  PanoUserService.m
//  PanoVideoCall
//
//  Created by pano on 2020/9/28.
//  Copyright © 2020 Pano. All rights reserved.
//

#import "PanoUserService.h"
#import "PanoClientService.h"
#import "UIImage+Extension.h"

@interface PanoUserService ()
@property (nonatomic, strong) NSMutableArray<PanoUserInfo *> *dataSource;
@property (nonatomic, strong, readonly) NSMutableDictionary *audioLevels;
@property (nonatomic, strong) NSDate *lastSpeakTime;

@property (nonatomic, strong) NSMutableDictionary *avators;
@property (nonatomic, assign) NSInteger imagesCount;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *offlineUsers;
@end

@implementation PanoUserService

- (void)initService {
    _dataSource = [NSMutableArray array];
    _audioLevels = [NSMutableDictionary dictionary];
    _offlineUsers = [NSMutableArray array];
    
    // 随机头像
    _avators = [NSMutableDictionary dictionary];
    _imagesCount = 22;
    _images = [NSMutableArray arrayWithCapacity:_imagesCount];
    for (NSInteger i=0; i<_imagesCount; i++) {
        [_images addObject:@(false)];
    }
}

- (void)notifyRefresh:(PanoUserInfo *)user {
    if (!PanoClientService.service.joined) return;
    [self invokeWithAction:@selector(onUserPropertyChanged:) completion:^(id <PanoUserDelegate> _Nonnull del) {
        [del onUserPropertyChanged:user];
    }];
}

- (void)onUserUpdated:(UInt64)userId message:(NSDictionary *)info {
    PanoUserInfo *user = [self findUserWithId:userId];
    [user setValuesForKeysWithDictionary:info[@"palyload"]];
}

- (void)onUserJoinIndication:(UInt64)userId withName:(NSString * _Nullable)userName {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"onUserJoinIndication: %lld, %@", userId, userName);
        if (!PanoClientService.service.joined) return;
        PanoUserInfo *user = [[PanoUserInfo alloc] initWithId:userId name:userName];
        [self.offlineUsers removeObject:user];
        if ([self.dataSource containsObject:user]) return;
        if (user.userId == PanoClientService.service.config.userId) {
            [self.dataSource insertObject:user atIndex:0];
        } else {
            [self.dataSource addObject:user];
        }
        [self invokeWithAction:@selector(onUserAdded:) completion:^(id <PanoUserDelegate>  _Nonnull del) {
            [del onUserAdded:user.copy];
        }];
    });
}

- (void)onUserLeaveIndication:(UInt64)userId
                   withReason:(PanoUserLeaveReason)reason {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!PanoClientService.service.joined) return;
        PanoUserInfo *user = [self findUserWithId:userId];
        NSLog(@"onUserLeaveIndication: %@, %ld", user, (long)reason);
        if (reason == kPanoLeaveDisconnected) {
            if (![self.offlineUsers containsObject:user]) {
                [self.offlineUsers addObject:user.copy]; // 缓存重连的用户
            }
            [self performSelector:@selector(checkOfflineUser:) withObject:[user copy] afterDelay:5];
        } else {
            // 断线用户重连成功后其它原因离开
            [self.offlineUsers removeObject:user];
            [self onUserLeave:user];
        }
    });
}

- (void)checkOfflineUser:(PanoUserInfo *)user {
    /**
     1. 检查10秒钟是否重连成功，无论重连成功与否，都从offlineUsers删除掉。
     2. 如果offlineUsers 还包含当前用户，那么通知上层
     3. 如果offlineUsers 不包括当前用户，说明重连成功
     */
    if ([self.offlineUsers containsObject:user] ) {
        [self onUserLeave:user];
    }
    [self.offlineUsers removeObject:user];
}

- (void)onUserLeave:(PanoUserInfo *)user {
    [self.dataSource removeObject:user];
    [self invokeWithAction:@selector(onUserRemoved:) completion:^(id <PanoUserDelegate>  _Nonnull del) {
        [del onUserRemoved:[user copy]];
    }];
}

- (void)onUserAudioStart:(UInt64)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        PanoUserInfo *user = [self findUserWithId:userId];
        user.audioStatus = PanoUserAudio_Unmute;
        [self notifyRefresh:user];
    });
}

- (void)onUserAudioStop:(UInt64)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        PanoUserInfo *user = [self findUserWithId:userId];
        user.audioStatus = PanoUserAudio_None;
        [self notifyRefresh:user];
    });
}

- (void)onUserAudioMute:(UInt64)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        PanoUserInfo *user = [self findUserWithId:userId];
        user.audioStatus = PanoUserAudio_Mute;
        [self notifyRefresh:user];
    });
}

- (void)onUserAudioUnmute:(UInt64)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        PanoUserInfo *user = [self findUserWithId:userId];
        user.audioStatus = PanoUserAudio_Unmute;
        [self notifyRefresh:user];
    });
}

- (void)onUserAudioLevel:(PanoRtcAudioLevel *)level {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.audioLevels setObject:@(level.level) forKey:@(level.userId)];
    });
    if (self.lastSpeakTime == nil) {
        self.lastSpeakTime = [NSDate new];
    }
    if ([[NSDate new] timeIntervalSinceDate:self.lastSpeakTime]> 1) {
        self.lastSpeakTime = [NSDate new];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self invokeWithAction:@selector(onUserAudioLevelChanged) completion:^(id  _Nonnull del) {
                [del onUserAudioLevelChanged];
            }];
        });
    }
}

@end

@implementation PanoUserService (Extension)

- (PanoUserInfo *)host {
    return [self findUserWithId:PanoClientService.service.hostUserId];
}

- (PanoUserInfo *)me {
    return self.dataSource.firstObject;
}

- (PanoUserInfo *)findUserWithId:(UInt64)userId {
    for (PanoUserInfo * userInfo in self.dataSource) {
        if (userInfo.userId == userId) {
            return userInfo;
        }
    }
    return nil;
}

- (NSArray<PanoUserInfo *> *)allUsers {
    return self.dataSource.copy;
}

- (NSArray<PanoUserInfo *> *)allUserExceptMe {
    if (self.dataSource.count <= 1) {
        return @[];
    }
    return [_dataSource subarrayWithRange:NSMakeRange(1, _dataSource.count-1)];
}

- (BOOL)isHost {
    return PanoClientService.service.config.userMode == PanoAnchor;
}

- (NSUInteger)totalCount {
    return _dataSource.count;
}

#pragma mark -- Extension

- (NSInteger)hashValue:(UInt64)hashId {
    NSInteger value = hashId % self.imagesCount;
    if (![self.images[value] boolValue]) {
        self.images[value] = @(true);
        return value;
    }
    for (NSInteger i=0; i<self.imagesCount; i++) {
        if (![self.images[i] boolValue]) {
            self.images[i] = @(true);
            return i;
        }
    }
    return value;
}

- (UIImage *)avatorImage:(UInt64)userId {
    NSString *imageName = self.avators[@(userId)];
    if (imageName) {
        return [UIImage imageNamed:imageName];
    }
    NSInteger value = [self hashValue:userId];
    NSString *prefix = value > 9 ? @"" : @"0";
    imageName = [NSString stringWithFormat:@"%@%ld",prefix, (long)value];
    [self.avators setObject:imageName forKey:@(userId)];
    return [UIImage imageNamed:imageName];
}

@end


@implementation  PanoUserInfo (Add)

- (BOOL)isActiving{
    NSInteger level = [[PanoClientService.service.userService.audioLevels objectForKey:@(self.userId)] intValue];
    if (level > 500) {
        return true;
    }
    return false;
}

- (UIImage *)avatorImage {
    return [PanoClientService.service.userService avatorImage:self.userId];
}

@end
