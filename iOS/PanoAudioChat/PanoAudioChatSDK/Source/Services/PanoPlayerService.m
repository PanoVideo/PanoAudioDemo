//
//  PanoPlayerService.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/15.
//

#import "PanoPlayerService.h"
#import "PanoClientService.h"

@interface PanoPlayerService ()

@property (nonatomic, strong)NSMutableArray *allAudios;
@property (nonatomic, assign)BOOL activeAudioIsPaused;
@end

@implementation PanoPlayerService

- (instancetype)init
{
    self = [super init];
    if (self) {
        _audioNames = @[@"音乐1", @"音乐2" , @"音乐3"];
        _soundNames = @[@"哈哈哈", @"哇哦" , @"鼓掌" ,@"尴尬", @"乌鸦" , @"起哄"];
        _allAudios = [NSMutableArray array];
        _activeAudioName = @"";
        _activeAudioIsPaused = false;
    }
    return self;
}

- (void)loadMusicResouces {
    [_allAudios addObjectsFromArray:_audioNames];
    [_allAudios addObjectsFromArray:_soundNames];
    for (NSInteger index=0; index<_audioNames.count; index++) {
        NSString *name = _audioNames[index];
        NSString *path = [NSBundle.mainBundle pathForResource:name ofType:@"mp3"];
        if (path) {
            [PanoClientService.service.engineKit createAudioMixingTask:index filename:path];
        }
    }
    for (NSInteger index=0; index<_soundNames.count; index++) {
        NSString *name = _soundNames[index];
        NSString *path = [NSBundle.mainBundle pathForResource:name ofType:@"caf"];
        SInt64 taskId = index + _audioNames.count;
        if (path) {
            [PanoClientService.service.engineKit createAudioMixingTask:taskId filename:path];
        }
    }
}

- (void)unLoadMusicResouces {
    for (NSInteger i=0; i<_allAudios.count; i++) {
        [PanoClientService.service.engineKit destroyAudioMixingTask:i];
    }
}

- (void)startSoundEffectTask:(NSString *)fileName withVolume:(UInt32)volume {
    NSUInteger taskId = [_allAudios indexOfObject:fileName];
    if (taskId == NSNotFound) {
        return;
    }
    PanoRtcAudioMixingConfig *config = [PanoRtcAudioMixingConfig new];
    config.publishVolume = volume;
    config.loopbackVolume = volume;
    config.enableLoopback = true;
    [PanoClientService.service.engineKit startAudioMixingTask:taskId withConfig:config];
}

- (void)stopSoundEffectTask:(NSString *)fileName {
    NSUInteger taskId = [_allAudios indexOfObject:fileName];
    if (taskId == NSNotFound) {
        return;
    }
    [PanoClientService.service.engineKit stopAudioMixingTask:taskId];
}

 - (void)startAudioMixingTask:(NSString *)fileName withVolume:(UInt32)volume {
     NSUInteger taskId = [_allAudios indexOfObject:fileName];
     if (taskId == NSNotFound) {
         return;
     }
     [self stopAudioMixingTask:_activeAudioName];
     _activeAudioName = fileName;
     PanoRtcAudioMixingConfig *config = [PanoRtcAudioMixingConfig new];
     config.publishVolume = volume;
     config.loopbackVolume = volume;
     config.enableLoopback = true;
     config.cycle = 0;
     _activeAudioIsPaused = false;
     [PanoClientService.service.engineKit startAudioMixingTask:taskId withConfig:config];
}

- (void)updateAudioMixingTask:(NSString *)fileName withVolume:(UInt32)volume {
    NSUInteger taskId = [_allAudios indexOfObject:fileName];
    if (taskId == NSNotFound) {
        return;
    }
    PanoRtcAudioMixingConfig *config = [PanoRtcAudioMixingConfig new];
    config.publishVolume = volume;
    config.loopbackVolume = volume;
    config.enableLoopback = true;
    config.cycle = 0;
    [PanoClientService.service.engineKit updateAudioMixingTask:taskId withConfig:config];
}

- (void)stopAudioMixingTask:(NSString *)fileName {
    NSUInteger taskId = [_allAudios indexOfObject:fileName];
    if (taskId == NSNotFound) {
        return;
    }
    [PanoClientService.service.engineKit stopAudioMixingTask:taskId];
    _activeAudioName = @"";
}

- (void)resumeAudioMixing:(NSString *)fileName {
    NSUInteger taskId = [_allAudios indexOfObject:fileName];
    if (taskId == NSNotFound) {
        return;
    }
    _activeAudioIsPaused = false;
    [PanoClientService.service.engineKit resumeAudioMixing:taskId];
}

- (void)pauseAudioMixing:(NSString *)fileName {
     NSUInteger taskId = [_allAudios indexOfObject:fileName];
     if (taskId == NSNotFound) {
         return;
     }
     _activeAudioIsPaused = true;
     [PanoClientService.service.engineKit pauseAudioMixing:taskId];
}

@end

@implementation PanoPlayerService (Extension)

- (void)updateVolume:(UInt32)volume {
    if (self.activeAudioIsPaused) return;
    if ([self.activeAudioName isEqualToString:@""]) return;
    [self updateAudioMixingTask:_activeAudioName withVolume:volume];
}

- (void)chooseNextAction {
    NSUInteger taskId = [_allAudios indexOfObject:_activeAudioName];
    if (taskId == NSNotFound) {
        [self startAudioMixingTask:_audioNames.firstObject withVolume:100];
    } else {
        NSUInteger nextAudio = (taskId + 1) % _audioNames.count;
        [self startAudioMixingTask:_audioNames[nextAudio] withVolume:100];
    }
}

- (void)startPlayAction:(BOOL)pause {
    if ([self isMusicPlaying]) {
        if (pause) {
            [self stopAudioMixingTask:_activeAudioName];
        } else {
            [self resumeAudioMixing:_activeAudioName];
        }
    } else {
        [self startAudioMixingTask:_audioNames.firstObject withVolume:100];
    }
}

- (BOOL)isMusicPlaying {
    if ([_activeAudioName isEqualToString:@""]) {
        return false;
    }
    NSUInteger taskId = [_allAudios indexOfObject:_activeAudioName];
    return taskId != NSNotFound;
}

- (BOOL)isAudioPaused {
    return _activeAudioIsPaused;
}

@end
