//
//  PanoMessage.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoMessage.h"
#import "PanoClientService.h"
#import "PanoMessageDefine.h"
#import "PanoDefine.h"

@implementation PanoMessage

- (instancetype)initWithContent:(NSString *)text
                           type:(PanoChatMessageType)type
                       fromUser:(UInt64)fromUser {
    self = [super init];
    if (self) {
        self.content = text;
        self.type = type;
        self.fromUser = fromUser;
    }
    return self;
}

- (NSDictionary *)toSendMessage {
    id data =  @{
        PanoMsgUserId : @(PanoClientService.service.userId),
        PanoMsgChatContent : _content ?: @""
    };
    return [[[PanoCmdMessage alloc] initWithCmd:normalChat data:data] toDictionary];
}

- (BOOL)isMySendMeesage {
    return self.fromUser != 0 && self.fromUser == PanoClientService.service.userId;
}

- (void)caculateWidth:(CGFloat)width {
    self.size = [self.content boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : fontMedium()} context:NULL].size;
}

- (id)copyWithZone:(NSZone *)zone {
    PanoMessage *msg = [[PanoMessage alloc] init];
    msg.content = self.content;
    msg.type = self.type;
    msg.fromUser = self.fromUser;
    msg.size = self.size;
    return msg;
}

@end
