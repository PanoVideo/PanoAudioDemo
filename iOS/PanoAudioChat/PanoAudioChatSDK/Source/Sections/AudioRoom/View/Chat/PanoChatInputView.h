//
//  PanoChatInputView.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoBaseView.h"
#import "PanoGrowingTextView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PanoChatInputViewDelegate <NSObject>

- (void)didSendText:(NSString *)text;

- (void)keyboardWillShow:(CGFloat)height;

- (void)keyboardWillChange:(CGFloat)height;

- (void)keyboardWillHide;

- (void)showEarMonitoringView;

- (void)exitChat;

- (BOOL)toggleAudio;

@end

@interface PanoChatInputView : PanoBaseView {
    @package
    PanoGrowingTextView *textView;
}

@property (nonatomic, weak) id <PanoChatInputViewDelegate> delegate;

- (void)updateControlView:(BOOL)isHost chat:(BOOL)isChating;
@end

NS_ASSUME_NONNULL_END
