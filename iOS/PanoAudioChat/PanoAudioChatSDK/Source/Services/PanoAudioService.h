//
//  PanoAudioService.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/15.
//

#import <Foundation/Foundation.h>
#import "PanoBaseService.h"

NS_ASSUME_NONNULL_BEGIN

@interface PanoAudioService : PanoBaseService

@property (nonatomic, assign) BOOL isMuted;

- (void)muteAudio;

- (void)unmuteAudio;

- (void)toggleAudio;

- (void)startAudio:(BOOL)mute;

- (void)stopAudio;

- (BOOL)isEnabledLoudspeaker;

- (void)setLoudspeakerStatus:(BOOL)staus;

- (void)startAudioDump:(NSTimeInterval)timeinterval;

- (void)stopAudioDump;

- (void)enableAudioEarMonitoring:(BOOL)enable;

- (void)setAudioDeviceVolume:(UInt32)volume;

+ (BOOL)hasHeadphonesDevice;

@end

NS_ASSUME_NONNULL_END
