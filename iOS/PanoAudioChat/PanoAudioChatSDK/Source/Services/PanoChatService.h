//
//  PanoChatService.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import <Foundation/Foundation.h>
#import "PanoMessage.h"
#import "PanoBaseService.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PanoChatDelegate <NSObject>

- (void)onReceiveMessage:(PanoMessage *)msg;

@end

@interface PanoChatService : PanoBaseService

@property (nonatomic, weak) id <PanoChatDelegate> delegate;

- (void)start;

- (void)sendTextMessage:(NSString*)text;

- (void)sendSystemMessage:(NSString*)text;


@end

NS_ASSUME_NONNULL_END
