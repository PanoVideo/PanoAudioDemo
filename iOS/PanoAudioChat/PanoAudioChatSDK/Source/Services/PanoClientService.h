//
//  PanoClientService.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/15.
//

#import <Foundation/Foundation.h>
#import <PanoRtc/PanoRtcEngineKit.h>
#import "PanoSignalInterface.h"
#import "PanoSignalService.h"
#import "PanoUserService.h"
#import "PanoAudioService.h"
#import "PanoPlayerService.h"
#import "PanoChatService.h"
#import "PanoClientConfig.h"


@protocol PanoClientMessageDelegate <NSObject>

/// 信令消息回调通知

- (void)onReceivedMessage:(NSDictionary<NSString *,id> *_Nullable)message fromUser:(UInt64)userId ;

@optional
/// rtms 状态回调
- (void)onRtmStateChanged:(BOOL)available;

@end

@protocol PanoClientPropertyDelegate <NSObject>

/// 属性改变通知
- (void)onPropertyChanged:(NSDictionary * _Nullable )value forKey:(NSString *_Nonnull)key;

@end

@protocol PanoClientDelegate <PanoClientMessageDelegate, PanoClientPropertyDelegate>

@optional
/// 显示退出房间的提示框
- (void)showExitRoomAlert:(NSString *_Nullable)message;

@end

NS_ASSUME_NONNULL_BEGIN

@interface PanoClientService : PanoBaseService

@property (strong, nonatomic, readonly) PanoClientConfig *config;
@property (copy, nullable, nonatomic) PanoCompletionBlock joinBlock;

@property (strong, nonatomic) NSString * roomId;
@property (strong, nonatomic) NSString * userName;
@property (assign, nonatomic) UInt64 userId;
@property (assign, nonatomic) BOOL audioDebug;
@property (assign, nonatomic) BOOL audioAdvanceProcess;
@property (assign, nonatomic) PanoAudioVoiceChangerOption audioVoiceChanger;
@property (assign, nonatomic) UInt64 hostUserId;
@property (assign, nonatomic) PanoMsgType uploadlogType;
@property (strong, nonatomic) NSString *uploadlogMessage;
@property (assign, nonatomic) BOOL joined;

@property (strong, nonatomic, readonly) PanoRtcEngineKit *engineKit;
@property (strong, nonatomic, readonly) PanoUserService *userService;
@property (strong, nonatomic, readonly) PanoAudioService *audioService;
@property (strong, nonatomic, readonly) PanoSignalService *signalService;
@property (strong, nonatomic, readonly) PanoPlayerService *playerService;
@property (strong, nonatomic, readonly) PanoChatService *chatService;
@property (assign, nonatomic, readonly) PanoMessageServiceState rtmState;


+ (instancetype)service;

- (void)startWithConfig:(PanoClientConfig *)config;

- (void)createEngineKit;

- (void)destroyEngineKit;

@end

NS_ASSUME_NONNULL_END
