//
//  PanoClientService.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/15.
//

#import "PanoClientService.h"
#import "PanoMulticastDelegate.h"
#import "AppConfig.h"
#import "PanoAudioRoomController.h"

@interface PanoClientService () <PanoRtcMessageDelegate, PanoRtcEngineDelegate>
@property (strong, nonatomic) PanoMulticastDelegate *delegates;
@end

@implementation PanoClientService

- (instancetype)init
{
    self = [super init];
    if (self) {
        _joined = false;
        _userName = @"";
        _audioDebug = false;
        _roomId = @"";
        _userId = 0;
        _audioAdvanceProcess = true;
        _audioVoiceChanger = kPanoVoiceChangerNone;
    }
    return self;
}

+ (instancetype)service {
    static PanoClientService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PanoClientService alloc] init];
    });
    return instance;
}

- (void)startWithConfig:(PanoClientConfig *)config {
    _config = config;
    _uploadlogType = PanoMsgNone;
    _signalService = [[PanoSignalService alloc] init];
    _userService = [[PanoUserService alloc] init];
    _audioService = [[PanoAudioService alloc] init];
    _playerService = [[PanoPlayerService alloc] init];
    _chatService = [[PanoChatService alloc] init];
}

- (void)setAudioVoiceChanger:(PanoAudioVoiceChangerOption)audioVoiceChanger {
    _audioVoiceChanger = audioVoiceChanger;
    if (_engineKit) {
        [_engineKit setOption:@(audioVoiceChanger) forType:kPanoOptionAudioVoiceChangerMode];
    }
}
- (void)createEngineKit {
    [self destroyEngineKit];
    PanoRtcEngineConfig * engineConfig = [[PanoRtcEngineConfig alloc] init];
    engineConfig.appId = [AppConfig appID];
    engineConfig.rtcServer = [AppConfig rtcServerURL];
    _engineKit = [PanoRtcEngineKit engineWithConfig:engineConfig delegate:self];
    [PanoRtcEngineKit setLogLevel:kPanoLogInfo];
    _engineKit.messageService.delegate = self;
}


- (void)destroyEngineKit {
    _engineKit.messageService.delegate = nil;
    [_engineKit.whiteboardEngine close];
    [_engineKit leaveChannel];
    [_engineKit destroy];
}

- (void)initAudioChanger {
    [_engineKit setOption:@(self.audioVoiceChanger) forType:kPanoOptionAudioVoiceChangerMode];
}

#pragma mark - PanoRtcMessageDelegate

- (void)onServiceStateChanged:(PanoMessageServiceState)state reason:(PanoResult)reason {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_rtmState = state;
        NSLog(@"onServiceStateChanged: %zd %zd", state, reason);
        [self invokeWithAction:@selector(onRtmStateChanged:) completion:^(id  _Nonnull del) {
            [del onRtmStateChanged:state == kPanoMessageServiceAvailable];
        }];
    });
}

- (void)onPropertyChanged:(NSArray<PanoPropertyAction *> *)props {
    NSLog(@"onPropertyChanged:%@",props);
    dispatch_async(dispatch_get_main_queue(), ^{
        for (PanoPropertyAction *prop in props) {
            [self invokeWithAction:@selector(onPropertyChanged:forKey:) completion:^(id  _Nonnull del) {
                NSDictionary *value = nil;
                if (prop.propValue) {
                    value = [NSJSONSerialization JSONObjectWithData:prop.propValue options:0 error:nil];
                }
                [del onPropertyChanged:value forKey:prop.propName];
            }];
        }
    });
}

- (void)onUserMessage:(UInt64)userId data:(NSData *)data {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (data.length <= 0) {
            return;
        }
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (!result) {
            return;
        }
        NSLog(@"onUserMessage:%@",result);
        [self invokeWithAction:@selector(onReceivedMessage:fromUser:) completion:^(id  _Nonnull del) {
            [del onReceivedMessage:result fromUser:userId];
        }];
        PanoCmdMessage *cmd = [[PanoCmdMessage alloc] initWithDict:result];
        if (cmd.cmd == uploadAudioLog) {
            [self.audioService startAudioDump:60];
            self.uploadlogType = uploadAudioLog;
        }
    });
}


- (void)onJoined:(PanoResult)result {
    if (!self.joined) return;
    BOOL success = result == kPanoResultOK;
    if (self.joinBlock) {
        NSError *error = nil;
        if (!success) {
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:result userInfo:nil];
        }
        self.joinBlock(error);
        self.joinBlock = nil;
    }
    if (success) {
        [self.audioService startAudio:self.config.userMode != PanoAnchor];
        [self.audioService setLoudspeakerStatus:true];
        [self.engineKit setAudioDeviceVolume:125 withType:kPanoDeviceAudioPlayout];
        [self.playerService loadMusicResouces];
        [self initAudioChanger];
    } else {
        [self invokeWithAction:@selector(showExitRoomAlert:) completion:^(id  _Nonnull del) {
            [del showExitRoomAlert: nil];
        }];
    }
}

#pragma mark - PanoRtcEngineDelegate

- (void)onChannelJoinConfirm:(PanoResult)result {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self onJoined:result];
    });
}

- (void)onChannelLeaveIndication:(PanoResult)result {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self invokeWithAction:@selector(onChannelLeaveIndication:) completion:^(id  _Nonnull del) {
            [del onChannelLeaveIndication:result];
        }];
    });
}

- (void)onChannelFailover:(PanoFailoverState)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self invokeWithAction:@selector(onChannelFailover:) completion:^(id  _Nonnull del) {
            [del onChannelFailover:state];
        }];
    });
}

- (void)onChannelCountDown:(UInt32)remain {
    // 会议时长结束通知
}

- (void)onUserJoinIndication:(UInt64)userId withName:(NSString * _Nullable)userName {
    [_userService onUserJoinIndication:userId withName:userName];
}

- (void)onUserLeaveIndication:(UInt64)userId
                   withReason:(PanoUserLeaveReason)reason {
    [_userService onUserLeaveIndication:userId withReason:reason];
}

- (void)onUserAudioStart:(UInt64)userId {
    [_userService onUserAudioStart:userId];
}

- (void)onUserAudioStop:(UInt64)userId {
    [_userService onUserAudioStop:userId];
}

- (void)onUserAudioSubscribe:(UInt64)userId
                  withResult:(PanoSubscribeResult)result {
    [_userService onUserAudioSubscribe:userId withResult:result];
}


- (void)onUserAudioMute:(UInt64)userId {
    [_userService onUserAudioMute:userId];
}

- (void)onUserAudioUnmute:(UInt64)userId {
    [_userService onUserAudioUnmute:userId];
}

- (void)onUserAudioLevel:(PanoRtcAudioLevel * _Nonnull)level {
    if (!self.joined) {
        return;
    }
    [_userService onUserAudioLevel:level];
}

@end
