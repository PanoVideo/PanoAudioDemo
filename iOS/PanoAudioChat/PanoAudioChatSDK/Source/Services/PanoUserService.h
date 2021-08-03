//
//  PanoUserService.h
//  PanoVideoCall
//
//  Created by pano on 2020/9/28.
//  Copyright © 2020 Pano. All rights reserved.
//

#import "PanoBaseService.h"
#import "PanoUserInfo.h"
#import <PanoRtc/PanoRtcEngineKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PanoUserChangedBlock_t)(PanoUserInfo *user);

@protocol PanoUserDelegate <NSObject>

@optional

- (void)onUserPropertyChanged:(PanoUserInfo *)user;

- (void)onUserRemoved:(PanoUserInfo *)user;

- (void)onUserAdded:(PanoUserInfo *)user;

- (void)onUserAudioLevelChanged;

@end

@interface PanoUserService : PanoBaseService <PanoRtcEngineDelegate>

@property (nonatomic, copy) PanoUserChangedBlock_t userChangeBlock;

@property (nonatomic, weak) id <PanoUserDelegate> delegate;

@end

@interface PanoUserService (Extension)

- (PanoUserInfo *)host;

- (PanoUserInfo *)me;

- (PanoUserInfo *)findUserWithId:(UInt64)userId;

- (NSArray<PanoUserInfo *> *)allUsers;

- (NSArray<PanoUserInfo *> *)allUserExceptMe;

- (BOOL)isHost;

- (UIImage *)avatorImage:(UInt64)userId;

- (NSUInteger)totalCount;

@end

@interface PanoUserService(Private)

- (void)onUserUpdated:(UInt64)userId message:(NSDictionary *)info;

@end

NS_ASSUME_NONNULL_END
