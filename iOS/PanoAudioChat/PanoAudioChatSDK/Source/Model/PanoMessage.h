//
//  PanoMessage.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PanoChatMessageType) {
    PanoChatMessage = 0,
    PanoSystemMessage = 1
};

@interface PanoMessage : NSObject <NSCopying>

@property (nonatomic, copy) NSString *content;

@property (nonatomic, assign) PanoChatMessageType type;

@property (nonatomic, assign) UInt64 fromUser;

@property (nonatomic, assign) CGSize size;

- (NSDictionary *)toSendMessage;

- (instancetype)initWithContent:(NSString *)text
                           type:(PanoChatMessageType)type
                       fromUser:(UInt64)fromUser;

- (BOOL)isMySendMeesage;

- (void)caculateWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
