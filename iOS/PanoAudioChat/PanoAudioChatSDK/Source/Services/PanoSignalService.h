//
//  PanoSignalService.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/15.
//

#import <Foundation/Foundation.h>
#import "PanoSignalInterface.h"
#import "PanoMessageDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface PanoSignalService : NSObject

- (BOOL)sendInviteMsg:(PanoMicInfo *)micInfo;

- (BOOL)sendAcceptInviteMsg:(PanoMicInfo *)micInfo;

- (BOOL)sendRejectInviteMsg:(PanoMicInfo*)micInfo
                     reason:(PanoCmdReason)reason;

- (BOOL)sendkillMsg:(PanoMicInfo *)micInfo;

- (BOOL)sendApplyChatMsg:(PanoMicInfo *)micInfo;

- (BOOL)sendCancelChatMsg:(PanoMicInfo *)micInfo;

- (BOOL)sendAcceptChatMsg:(PanoMicInfo *)micInfo;

- (BOOL)sendRejectChatMsg:(PanoMicInfo*)micInfo
                   reason:(PanoCmdReason)reason;

- (BOOL)sendStopChatMsg:(PanoMicInfo *)micInfo;

- (BOOL)sendCloseRoomMsg;

@end

NS_ASSUME_NONNULL_END
