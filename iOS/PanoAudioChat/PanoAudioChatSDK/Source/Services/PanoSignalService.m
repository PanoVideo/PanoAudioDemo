//
//  PanoSignalService.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/15.
//

#import "PanoSignalService.h"
#import "PanoClientService+OpenApi.h"


@implementation PanoSignalService

- (id <PanoSignalInterface>)signalService {
    return PanoClientService.service;
}

- (BOOL)sendInviteMsg:(PanoMicInfo *)micInfo {
    NSDictionary *params = [[[PanoMicMessage alloc] initWithCmd:inviteUser data:@[micInfo] reason:ok] toDictionary];
    return [self.signalService sendMessage:params toUser:micInfo.userId];
}

- (BOOL)sendAcceptInviteMsg:(PanoMicInfo *)micInfo {
    NSDictionary *params = [[[PanoMicMessage alloc] initWithCmd:acceptInvite data:@[micInfo] reason:ok] toDictionary];
    return [self.signalService sendMessage:params toUser:PanoClientService.service.hostUserId];
}

- (BOOL)sendRejectInviteMsg:(PanoMicInfo*)micInfo
                     reason:(PanoCmdReason)reason {
    NSDictionary *params = [[[PanoMicMessage alloc] initWithCmd:rejectInvite data:@[micInfo] reason:reason] toDictionary];
    return [self.signalService sendMessage:params toUser:PanoClientService.service.hostUserId];
}

- (BOOL)sendkillMsg:(PanoMicInfo *)micInfo {
    NSDictionary *params = [[[PanoMicMessage alloc] initWithCmd:killUser data:@[micInfo] reason:ok] toDictionary];
    return [self.signalService sendMessage:params toUser:micInfo.userId];
}

- (BOOL)sendApplyChatMsg:(PanoMicInfo *)micInfo {
    NSDictionary *params = [[[PanoMicMessage alloc] initWithCmd:applyChat data:@[micInfo] reason:ok] toDictionary];
    return [self.signalService sendMessage:params toUser:PanoClientService.service.hostUserId];
}

- (BOOL)sendCancelChatMsg:(PanoMicInfo *)micInfo {
    NSDictionary *params = [[[PanoMicMessage alloc] initWithCmd:cancelChat data:@[micInfo] reason:ok] toDictionary];
    return [self.signalService sendMessage:params toUser:PanoClientService.service.hostUserId];
}

- (BOOL)sendAcceptChatMsg:(PanoMicInfo *)micInfo {
    NSDictionary *params = [[[PanoMicMessage alloc] initWithCmd:acceptChat data:@[micInfo] reason:ok] toDictionary];
    return [self.signalService sendMessage:params toUser:micInfo.userId];
}

- (BOOL)sendRejectChatMsg:(PanoMicInfo*)micInfo
                   reason:(PanoCmdReason)reason {
    NSDictionary *params = [[[PanoMicMessage alloc] initWithCmd:rejectChat data:@[micInfo] reason:reason] toDictionary];
    return [self.signalService sendMessage:params toUser:micInfo.userId];
}

- (BOOL)sendStopChatMsg:(PanoMicInfo *)micInfo {
    NSDictionary *params = [[[PanoMicMessage alloc] initWithCmd:stopChat data:@[micInfo] reason:ok] toDictionary];
    return [self.signalService sendMessage:params toUser:PanoClientService.service.hostUserId];
}

- (BOOL)sendCloseRoomMsg {
    NSDictionary *params = [[[PanoMicMessage alloc] initWithCmd:closeRoom data:nil reason:ok] toDictionary];
    return [self.signalService broadcastMessage:params];
}

@end
