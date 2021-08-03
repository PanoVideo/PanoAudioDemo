//
//  PanoAudioService.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/15.
//

#import "PanoAudioService.h"
#import "PanoClientService.h"
#import <AVFoundation/AVFoundation.h>

NSString *PanoAudioDumpFileName = @"pano_audio.dump";

UInt64 PanoMaxAudioDumpFileSize = 200 * 1024 * 1024;

@implementation PanoAudioService

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isMuted = false;
    }
    return self;
}

- (UInt64)userId {
    return PanoClientService.service.config.userId;
}

- (void)muteAudio {
    _isMuted = true;
    [PanoClientService.service.engineKit muteAudio];
    [PanoClientService.service.userService onUserAudioMute:self.userId];
}

- (void)unmuteAudio {
    _isMuted = false;
    [PanoClientService.service.engineKit unmuteAudio];
    [PanoClientService.service.userService onUserAudioUnmute:self.userId];
}

- (void)toggleAudio {
    _isMuted ? [self unmuteAudio] : [self muteAudio];
}

- (void)startAudio:(BOOL)mute {
    [PanoClientService.service.engineKit startAudio];
    [PanoClientService.service.userService onUserAudioStart:self.userId];
    if (mute) {
        [self muteAudio];
    }
}


- (void)stopAudio {
    [PanoClientService.service.engineKit stopAudio];
    [PanoClientService.service.userService onUserAudioStop:self.userId];
}

- (BOOL)isEnabledLoudspeaker {
    return [PanoClientService.service.engineKit isEnabledLoudspeaker];
}

- (void)setLoudspeakerStatus:(BOOL)staus {
    [PanoClientService.service.engineKit setLoudspeakerStatus:staus];
}

- (void)startAudioDump:(NSTimeInterval)timeinterval {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSString *panoAudioDumpFile = [NSTemporaryDirectory() stringByAppendingPathComponent:PanoAudioDumpFileName];
    [PanoClientService.service.engineKit startAudioDumpWithFilePath:panoAudioDumpFile maxFileSize:PanoMaxAudioDumpFileSize];
    if (timeinterval > 0) {
        [self performSelector:@selector(stopAudioDump) withObject:nil afterDelay:timeinterval];
    }
}

- (void)stopAudioDump {
    [PanoClientService.service.engineKit stopAudioDump];
}

- (void)enableAudioEarMonitoring:(BOOL)enable {
    [PanoClientService.service.engineKit setOption:@(enable) forType:kPanoOptionAudioEarMonitoring];
}

- (void)setAudioDeviceVolume:(UInt32)volume {
    [PanoClientService.service.engineKit setAudioDeviceVolume:volume withType:kPanoDeviceAudioRecord];
}

+ (BOOL)hasHeadphonesDevice {
    AVAudioSessionRouteDescription *route = AVAudioSession.sharedInstance.currentRoute;
    for (AVAudioSessionPortDescription *port in route.outputs) {
        if ([port.portType isEqualToString: AVAudioSessionPortHeadphones] ||
            [port.portType isEqualToString: AVAudioSessionPortBluetoothLE] ||
            [port.portType isEqualToString: AVAudioSessionPortBluetoothHFP] ||
            [port.portType isEqualToString: AVAudioSessionPortBluetoothA2DP]) {
            return true;
        }
    }
    return false;
}

@end
