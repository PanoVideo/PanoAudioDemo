//
//  PanoAudioPlayerView.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PanoAudioPlayerDelegate <NSObject>

- (void)didChooseNextAction;

- (void)didStartPlayAction:(BOOL)pause;

- (void)didShowMoreAction;

@end

@interface PanoAudioPlayerView : PanoBaseView {
    @package
    UIButton *playBtn;
}

@property (nonatomic, weak) id <PanoAudioPlayerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
