//
//  PanoClientService+App.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/15.
//

#import "PanoClientService+App.h"
#import "AppConfig.h"
#import "PanoClientService+OpenApi.h"

static NSString * kUserNameKey = @"com.pano.UserName";
static NSString * kRoomIdKey = @"com.pano.RoomId";
static NSString * kUserIdKey = @"com.pano.UserId";
static NSString * kAudioDebugKey = @"com.pano.AudioDebug";

static NSString * kAudioAdvanceProcess = @"com.pano.audioAdvanceProcess";
static NSString * kAudioVoiceChanger = @"com.pac.audioVoiceChanger";

static NSString * kHttpHeader = @"http";
static NSString * kHttpsHeader = @"https";
static NSString * kUrlCheckUpdateApi = @"app/checkUpdate";
static NSString * kUrlCheckLocationApi = @"app/checkLoc";
static NSString * kUrlLoginApi = @"app/token/v2";


@implementation PanoClientService (App)

- (void)savePreferences {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.userName forKey:kUserNameKey];
    [userDefaults setObject:self.roomId forKey:kRoomIdKey];
    [userDefaults setInteger:self.userId forKey:kUserIdKey];
    [userDefaults setBool:self.audioDebug forKey:kAudioDebugKey];
    
    [userDefaults setInteger:self.audioVoiceChanger forKey:kAudioVoiceChanger];
    [userDefaults setBool:self.audioAdvanceProcess forKey:kAudioAdvanceProcess];
    
    if (self.audioDebug) {
        [self.audioService startAudioDump:-1];
    } else {
        [self.audioService stopAudioDump];
    }
}

- (void)loadPreferences {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.userName = [userDefaults stringForKey:kUserNameKey];
    self.roomId = [userDefaults stringForKey:kRoomIdKey];
    self.userId = [userDefaults integerForKey:kUserIdKey];
    self.audioDebug = [userDefaults boolForKey:kAudioDebugKey];
    if ([userDefaults valueForKey:kAudioAdvanceProcess]) {
        self.audioAdvanceProcess = [userDefaults boolForKey:kAudioAdvanceProcess];
    }
    if ([userDefaults valueForKey:kAudioVoiceChanger]) {
        self.audioVoiceChanger = [userDefaults integerForKey:kAudioVoiceChanger];
    }
}

- (void)uploadlogsAutomatically {
    if (self.uploadlogType != PanoMsgNone) {
        self.uploadlogType = PanoMsgNone;
        NSString *detail = [NSString stringWithFormat:@"%@ 自动上传日志: %@", self.config.userName ,self.uploadlogMessage];
        [self sendFeedback:kPanoFeedbackAudio detail:detail uploadLogs:true contact:@""];
    }
}
- (void)sendFeedback:(PanoFeedbackType)type
              detail:(NSString *)detail
          uploadLogs:(BOOL)uploadLogs
             contact:(NSString *)contact {
    PanoFeedbackInfo * info = [PanoFeedbackInfo new];
    info.type = type;
    info.productName = [[self class] productName];
    info.detailDescription = detail;
    info.contact = contact;
    info.extraInfo = @"";
    info.uploadLogs = uploadLogs;
    [self.engineKit sendFeedback:info];
}

- (void)notifyOthersUploadLogs:(PanoFeedbackType)type
                       message:(NSString *)message
{
    self.uploadlogMessage = message;
    [self broadcastMessage:[[[PanoCmdMessage alloc] initWithCmd:uploadAudioLog data:nil] toDictionary]];
}

+ (NSString *)productName {
    return [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleName"];
}

+ (NSString *)productVersion {
    NSString * appVersion = [[self class] productShortVersion];
    NSString * sdkVersion = [PanoRtcEngineKit getSdkVersion];
    return [NSString stringWithFormat:@"v%@ (%@)", appVersion, sdkVersion];
}

+ (NSString *)productShortVersion {
    return [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

- (void)fetchTokenWithCompletionHandler:(void (^)(NSString *token, UInt64 hostUserId, NSError * error))completionHandler {
    /**
     *  SDK 到 Pano Cloud 的所有交互都需要使用 Token，Token的生成方式有两种。
     *   第一种是 App Server 通过 RESTful API 向 Pano 服务器获取。
     *   第二种是 App Server 按照 Pano 定义的规则本地生成
     *   请参考 https://developer.pano.video/restful/authtoken/
     *
     *   第三种 调试阶段 可以临时 Token, 可以在控制台创建应用
     *   请参考 https://console.pano.video/#/user/login
     *
     *   加入房间后需要获取到 "Token" 和  "主播的 UserId"，需要 客户的App Server 提供接口
     *
     *   创建语聊房  调试可以返回 "临时Token"  和 "当前用户的Userid"
     *   加入语聊房  调试可以返回 "临时Token"  和 "主播UserId"
     *
     *   客户的App Server 需要保证
     *   1. 同一个房间ID，同一时间 只能有一个主播加入
     */
    completionHandler(<#T##Token: String##String#>, <#T##主播的UserId: String##String#>, nil);
}

@end
