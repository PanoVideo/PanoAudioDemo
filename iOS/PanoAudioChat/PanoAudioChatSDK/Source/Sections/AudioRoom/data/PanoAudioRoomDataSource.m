//
//  PanoAudioRoomDataSource.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoAudioRoomDataSource.h"
#import "PanoClientService.h"

// 总共的麦位数量
static NSInteger totalMicCount = 8;

@implementation PanoAudioRoomDataSource {

// 8个麦位
    NSMutableArray <PanoMicInfo *>* totalMicArray;

// 申请上麦的用户
    NSMutableArray <PanoMicInfo *>* applyMicArray;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commitInit];
    }
    return self;
}

- (void)commitInit {
    
    totalMicArray = [NSMutableArray array];
    
    applyMicArray = [NSMutableArray array];
    
    myMicInfo = [[PanoMicInfo alloc] init];
    
    myMicInfo.userId = PanoClientService.service.userId;
    
    // 初始化麦位信息
    for (NSInteger i=0; i<totalMicCount; i++) {
        PanoMicInfo *micInfo = [[PanoMicInfo alloc] init];
        micInfo.order = i;
        [totalMicArray addObject:micInfo];
    }
}

- (NSArray<PanoMicInfo *> *)allMics {
    NSArray *result = [[NSArray alloc] initWithArray:totalMicArray copyItems:true];
    return result;
}

- (NSArray *)allApplicants {
    return [applyMicArray copy];
}

- (void)resetMyMic {
    myMicInfo.status = PanoMicNone;
    myMicInfo.order = -1;
}

- (PanoMicInfo *)micInfo:(NSInteger)order {
    if (order >= 0 && order < totalMicCount) {
        return totalMicArray[order];
    }
    return nil;
}

/// 删除申请者
- (void)removeApplyUser:(PanoUserInfo *)user {
    NSMutableIndexSet *sets = [[NSMutableIndexSet alloc] init];
    for (NSInteger i=0; i<applyMicArray.count; i++) {
        if (applyMicArray[i].userId == user.userId) {
            [sets addIndex:i];
        }
    }
    [applyMicArray removeObjectsAtIndexes:sets];
}

/// 删除申请者
- (void)removeApplyUser:(PanoMicInfo *)mic deleteAll:(BOOL)all {
    if (all) {
        NSMutableArray *needTrimArray = [NSMutableArray array];
        NSMutableIndexSet *sets = [[NSMutableIndexSet alloc] init];
        for (NSInteger i=0; i<applyMicArray.count; i++) {
            if (applyMicArray[i].order == mic.order) {
                [sets addIndex:i];
                if (applyMicArray[i].userId != mic.userId) {
                    [needTrimArray addObject:applyMicArray[i]];
                }
            }
        }
        _applyBlock(needTrimArray, ok);
        [applyMicArray removeObjectsAtIndexes:sets];
    } else {
        NSUInteger index = [applyMicArray indexOfObject:mic];
        if (index != NSNotFound) {
            [applyMicArray removeObjectAtIndex: index];
        }
    }
}

/// 缓存申请用户
- (void)appendApplyUser:(PanoMicInfo *)mic {
    [self removeApplyUser:mic.user];
    [applyMicArray addObject:mic];
    NSTimeInterval curTimestamp = [[NSDate new] timeIntervalSince1970];
    if (mic.timestamp != 0) {
        NSTimeInterval delay = mic.timestamp / 1000  + PanoMsgExpireInterval - curTimestamp;
        [self performSelector:@selector(trimApplyUser) withObject:nil afterDelay:delay];
    }
}

/// 删除过期的申请用户
 - (void)trimApplyUser {
     NSTimeInterval curTimestamp = [[NSDate new] timeIntervalSince1970];
     NSMutableArray *needTrimArray = [NSMutableArray array];
     
     NSMutableIndexSet *sets = [[NSMutableIndexSet alloc] init];
     for (NSInteger i=0; i<applyMicArray.count; i++) {
         PanoMicInfo *mic = applyMicArray[i];
         if (mic.timestamp !=0 &&
             mic.timestamp / 1000 + PanoMsgExpireInterval <= curTimestamp) {
             [sets addIndex:i];
             [needTrimArray addObject:mic];
         }
     }
     [applyMicArray removeObjectsAtIndexes:sets];
     _applyBlock(needTrimArray, timeout);
}

/// 更新麦位信息
- (void)updateMicArrayWithMicInfo:(PanoMicInfo *)micInfo {
    if (micInfo.order >= 0 && micInfo.order < totalMicCount) {
        totalMicArray[micInfo.order] = micInfo;
        if (myMicInfo.userId == micInfo.userId) {
            myMicInfo.status = micInfo.status;
            myMicInfo.order = micInfo.order;
        }
    }
}

/// 更新所有麦位信息
- (void)updateMicArrayWithMicInfos:(NSArray <PanoMicInfo *>*)micInfos {
    if (micInfos.count == totalMicCount) {
        BOOL found = false;
        for (PanoMicInfo *item in micInfos) {
            [self updateMicArrayWithMicInfo:item];
            if (item.userId == myMicInfo.userId) {
                found = true;
            }
        }
        if (!found && myMicInfo.status != PanoMicNone) {
            [self resetMyMic];
        }
    }
}

/// 删除某个麦位
- (void)removeMicArray:(PanoMicInfo *)micInfo {
    [self updateMicArrayWithMicInfo:[[PanoMicInfo alloc] initWithStatus:PanoMicNone userId:0 order:micInfo.order]];
}


/// 删除麦位用户
- (void)removeMicUser:(PanoUserInfo *)user {
    if (user.userId == myMicInfo.userId) {
        myMicInfo.status = PanoMicNone;
        myMicInfo.order = -1;
    }
    for (NSInteger index = 0; index<totalMicCount; index++) {
        PanoMicInfo *info = totalMicArray[index];
        if (info.userId == user.userId) {
            PanoMicInfo *tempMicInfo = [[PanoMicInfo alloc] init];
            tempMicInfo.order = index;
            totalMicArray[index] = tempMicInfo;
            break;
        }
    }
}

/// 所有麦位在线的用户
- (NSArray <PanoUserInfo *>*)onlineUsers {
    NSMutableArray <PanoUserInfo *>*result = [NSMutableArray array];
    for (NSInteger index = 0; index<totalMicCount; index++) {
        PanoUserInfo *user = totalMicArray[index].user;
        if (user) {
            [result addObject:[user copy]];
        }
    }
    return result;
}

- (BOOL)containUser:(PanoUserInfo *)user {
    for (NSInteger index = 0; index<totalMicCount; index++) {
        if (totalMicArray[index].userId == user.userId) {
            return true;
        }
    }
    return false;
}

@end
