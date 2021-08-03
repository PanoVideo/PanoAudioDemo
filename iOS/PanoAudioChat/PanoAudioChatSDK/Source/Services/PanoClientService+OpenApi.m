//
//  PanoClientService+OpenApi.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/15.
//

#import "PanoClientService+OpenApi.h"
#import "PanoClientService+App.h"

@implementation PanoClientService (OpenApi)

- (void)joinWithConfigWithCompletion:(PanoCompletionBlock)block {
    self.joinBlock = block;
    PanoClientConfig *config = self.config;
    self.userName = config.userName;
    self.roomId = config.roomId;
    self.userId = config.userId;
    [self savePreferences];
    [self fetchTokenWithCompletionHandler:^(NSString * _Nonnull token, UInt64 hostUserId, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                block(error);
                return;
            }
            [self createEngineKit];
            PanoRtcChannelConfig *chanelConfig = [[PanoRtcChannelConfig alloc] init];
            chanelConfig.mode = kPanoChannelMeeting;
            chanelConfig.subscribeAudioAll = true;
            chanelConfig.userName = config.userName;
            PanoResult res = [self.engineKit joinChannelWithToken:token channelId:config.roomId userId:config.userId config:chanelConfig];
            if (res == kPanoResultOK) {
                self.joined = true;
                [self.userService onUserJoinIndication:config.userId withName:config.userName];
                UIApplication.sharedApplication.idleTimerDisabled = true;
                self.hostUserId = hostUserId;
            } else {
                block([NSError errorWithDomain:NSCocoaErrorDomain code:res userInfo:nil]);
            }
        });
    }];
}

- (void)leaveAudioRoom {
    if (!self.joined) {
        return;
    }
    self.joinBlock = nil;
    self.joined = false;
    NSTimeInterval after = 0.0;
    if (self.config.userMode == PanoAnchor) {
        /**
           关闭房间有两种方式，
            第一： 通过发送广播消息，然后大家离开会议
            第二：调用RestfulApi close channel
         */
        [self.signalService sendCloseRoomMsg];
        after = 1.5;
    }
    [self uploadlogsAutomatically];
    [self.audioService stopAudioDump];
    [self.playerService unLoadMusicResouces];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(after * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self destroyEngineKit];
        UIApplication.sharedApplication.idleTimerDisabled = false;
    });
}

- (UIViewController *)settingViewController {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Setting" bundle: bundle];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"setting"];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    return navi;
}

- (BOOL)sendMessage:(NSDictionary<NSString *,id> *)msg toUser:(UInt64)userId {
    if (self.rtmState == kPanoMessageServiceUnavailable) {
        return false;
    }
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:msg options:0 error:&error];
    if (error) {
        return false;
    }
    PanoResult result = [self.engineKit.messageService sendMessageToUser:userId data:data];
    return result == kPanoResultOK;
}

- (BOOL)broadcastMessage:(NSDictionary<NSString *,id> *)msg {
    if (self.rtmState == kPanoMessageServiceUnavailable) {
        return false;
    }
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:msg options:0 error:&error];
    if (error) {
        return false;
    }
    PanoResult result = [self.engineKit.messageService broadcastMessage:data sendBack:true];
    return result == kPanoResultOK;
}

- (BOOL)setProperty:(id)value forKey:(NSString *)key {
    if (self.rtmState == kPanoMessageServiceUnavailable) {
        return false;
    }
    NSData *data = nil;
    if (value) {
        NSError *error = nil;
        data = [NSJSONSerialization dataWithJSONObject:value options:0 error:&error];
    }
    PanoResult result = [self.engineKit.messageService setProperty:key value:data];
    return result == kPanoResultOK;
}

@end
