//
//  PanoPlayerService.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/15.
//

#import <Foundation/Foundation.h>
#import "PanoBaseService.h"

NS_ASSUME_NONNULL_BEGIN

@interface PanoPlayerService : PanoBaseService

@property (nonatomic, strong)NSArray *audioNames;

@property (nonatomic, strong)NSArray *soundNames;

@property (nonatomic, copy) NSString *activeAudioName;

- (void)loadMusicResouces;

- (void)unLoadMusicResouces;

- (void)startSoundEffectTask:(NSString *)fileName withVolume:(UInt32)volume;

- (void)stopSoundEffectTask:(NSString *)fileName;


- (void)startAudioMixingTask:(NSString *)fileName withVolume:(UInt32)volume;

- (void)updateAudioMixingTask:(NSString *)fileName withVolume:(UInt32)volume;

- (void)stopAudioMixingTask:(NSString *)fileName;

- (void)resumeAudioMixing:(NSString *)fileName;

- (void)pauseAudioMixing:(NSString *)fileName;

@end



@interface PanoPlayerService (Extension)

- (void)updateVolume:(UInt32)volume;

- (void)chooseNextAction;

- (void)startPlayAction:(BOOL)pause;

- (BOOL)isMusicPlaying;

- (BOOL)isAudioPaused;

@end

NS_ASSUME_NONNULL_END
