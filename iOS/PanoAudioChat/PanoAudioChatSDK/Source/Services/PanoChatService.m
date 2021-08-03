//
//  PanoChatService.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoChatService.h"
#import "PanoClientService+OpenApi.h"
#import "PanoUserInfo.h"

@interface PanoChatService () <PanoClientMessageDelegate, PanoUserDelegate>

@end

@implementation PanoChatService {
    NSMutableArray <PanoMessage *>* messages;
}

- (void)start {
    messages = [NSMutableArray array];
    
    [PanoClientService.service.userService addDelegate:self];
    
    [PanoClientService.service addDelegate:self];
}

- (void)sendTextMessage:(NSString*)text {
    PanoMessage *msg = [[PanoMessage alloc] initWithContent:text type:PanoChatMessage fromUser:0];
    [PanoClientService.service broadcastMessage:msg.toSendMessage];
}

- (void)sendSystemMessage:(NSString*)text {
    PanoMessage *msg = [[PanoMessage alloc] initWithContent:text type:PanoSystemMessage fromUser:0];
    [_delegate onReceiveMessage:msg];
}

// MARK: PanoUserDelegate
- (void)onUserAdded:(PanoUserInfo *)user {
    [self sendSystemMessage:[NSString stringWithFormat:@"'%@' %@", user.userName, NSLocalizedString(@"加入了房间", nil)]];
}

- (void)onUserRemoved:(PanoUserInfo *)user {
    [self sendSystemMessage:[NSString stringWithFormat:@"'%@' %@", user.userName, NSLocalizedString(@"离开了房间", nil)]];
}

// MARK: PanoClientDelegate
- (void)onReceivedMessage:(NSDictionary<NSString *,id> *)msg fromUser:(UInt64)userId {
    PanoCmdMessage *cmd = [[PanoCmdMessage alloc] initWithDict:msg];
    if (cmd && cmd.cmd == normalChat && cmd.data) {
        NSString *content = cmd.data[PanoMsgChatContent];
        UInt64 fromUser = [cmd.data[PanoMsgUserId] unsignedIntegerValue];
        NSMutableString *textContent = [[NSMutableString alloc] init];
        NSString *userName = [PanoClientService.service.userService findUserWithId:fromUser].userName;
        if (userName) {
            [textContent appendString:[NSString stringWithFormat:@"%@: ",userName]];
        }
        if (content) {
            [textContent appendString:content];
        }
        PanoMessage *msg = [[PanoMessage alloc] initWithContent:textContent type:PanoChatMessage fromUser: fromUser];
        [_delegate onReceiveMessage:msg];
    }
}


@end
