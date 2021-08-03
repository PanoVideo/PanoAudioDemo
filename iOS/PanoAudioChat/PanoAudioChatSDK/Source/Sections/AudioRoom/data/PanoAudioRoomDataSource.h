//
//  PanoAudioRoomDataSource.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import <Foundation/Foundation.h>
#import "PanoMicInfo.h"
#import "PanoMessageDefine.h"
#import "PanoClientConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ApplyArrayDidTrimmedBlock)(NSArray<PanoMicInfo *> * micInfos, PanoCmdReason reason  );
@interface PanoAudioRoomDataSource : NSObject {
    @package
    // 我自己的麦位信息
    PanoMicInfo *myMicInfo;
}

@property (nonatomic, assign) PanoUserMode userMode;

@property (nonatomic, copy) ApplyArrayDidTrimmedBlock applyBlock;

/// 所有麦位
- (NSArray <PanoMicInfo *> *)allMics;

/// 所有申请的麦位
- (NSArray <PanoMicInfo *> *)allApplicants;

/// 所有麦位在线的用户
- (NSArray <PanoUserInfo *>*)onlineUsers;


- (void)resetMyMic;


- (PanoMicInfo *)micInfo:(NSInteger)order;

/// 更新麦位信息
- (void)updateMicArrayWithMicInfo:(PanoMicInfo *)micInfo;

/// 更新所有麦位信息
- (void)updateMicArrayWithMicInfos:(NSArray <PanoMicInfo *>*)micInfos;

/// 删除申请者
- (void)removeApplyUser:(PanoMicInfo *)mic deleteAll:(BOOL)all;

/// 删除申请者
- (void)removeApplyUser:(PanoUserInfo *)user;

/// 缓存申请用户
- (void)appendApplyUser:(PanoMicInfo *)mic;

/// 删除麦位用户
- (void)removeMicUser:(PanoUserInfo *)user;

/// 删除某个麦位
- (void)removeMicArray:(PanoMicInfo *)micInfo;


- (BOOL)containUser:(PanoUserInfo *)user;

@end

NS_ASSUME_NONNULL_END
