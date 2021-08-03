//
//  PanoChatInputView.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoChatInputView.h"
#import "PanoGrowingTextView.h"
#import "PanoClientService.h"
#import "PanoDefine.h"

@implementation PanoChatInputView {
    
    UIView *inputContentView;
    
    UIStackView *controlView;
    
    UIButton *loudspeakerButton;
    
    UIButton *voiceButton;
    
    UIButton *earButton;
    
    UIButton *sendButton;
    
    UIStackView *sendStackView;
    
    void(^exitBlock)(void);
}

- (void)initViews {
    
    inputContentView = [UIView new];
    [self addSubview:inputContentView];
    
    textView = [[PanoGrowingTextView alloc] init];
    textView.placeholder = NSLocalizedString(@"聊两句", nil);
    textView.placeholderColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    textView.minHeight = 35.0;
    textView.maxHeight = 35.0;
    textView.font = [UIFont systemFontOfSize:14];
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.cornerRadius = 4.0;
    [inputContentView addSubview:textView];
    
    controlView = [UIStackView new];
    controlView.axis = UILayoutConstraintAxisHorizontal;
    controlView.distribution = UIStackViewDistributionFillEqually;
    controlView.spacing = 25;
    [self addSubview:controlView];
    
    loudspeakerButton = [self createMusicButton:nil image:[UIImage imageNamed:@"room_loudspeaker"]];
    loudspeakerButton.selected = false;
    [loudspeakerButton setImage:[UIImage imageNamed:@"room_loudspeaker_close"] forState:UIControlStateSelected];
    loudspeakerButton.enabled = PanoIsPhone();
    
    voiceButton = [self createMusicButton:nil image:[UIImage imageNamed:@"room_voice"]];
    [voiceButton setImage:[UIImage imageNamed:@"room_voice_mute"] forState:UIControlStateSelected];
    
    earButton = [self createMusicButton:nil image:[UIImage imageNamed:@"room_ear_monitor"]];
    
    [loudspeakerButton addTarget:self action:@selector(startLoudspeaker) forControlEvents:UIControlEventTouchUpInside];
    [voiceButton addTarget:self action:@selector(enableAudio) forControlEvents:UIControlEventTouchUpInside];
    [earButton addTarget:self action:@selector(showEarMonitorPage) forControlEvents:UIControlEventTouchUpInside];
    
    [controlView addArrangedSubview:loudspeakerButton];
    
    sendStackView = [[UIStackView alloc] init];
    sendStackView.axis = UILayoutConstraintAxisHorizontal;
    sendButton = [self createMusicButton:NSLocalizedString(@" 发送 ", nil) image:nil];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"home_bg_blue"] forState:UIControlStateNormal];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"home_bg_blue"] forState:UIControlStateHighlighted];
    [sendButton addTarget:self action:@selector(sendText) forControlEvents:UIControlEventTouchUpInside];
    sendButton.layer.cornerRadius = 15;
    sendButton.layer.masksToBounds = true;
    sendButton.frame = CGRectMake(0, 2.5, 120, 30);
    [sendStackView addArrangedSubview:sendButton];
    sendStackView.hidden = true;
    [self addSubview:sendStackView];
    [self addNotifications];
}

- (UIButton *)createMusicButton:(NSString *)title image:(UIImage *)image {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (title) {
        [button setTitle:title forState:UIControlStateNormal];
    }
    button.frame = CGRectMake(0, 0, 30, 30);
    if (image) {
        [button setImage:image forState:UIControlStateNormal];
        [button setImage:image forState:UIControlStateHighlighted];
    }
    return button;
}


- (void)initConstraints {
    [inputContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.mas_equalTo(self);
        make.height.mas_equalTo(60);
    }];
    
    [controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(controlView.superview).offset(-defaultMargin);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(inputContentView.mas_right).offset(8);
        make.centerY.mas_equalTo(textView);
    }];
    
    [sendStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(sendStackView.superview).offset(-defaultMargin);
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(inputContentView.mas_right).offset(8);
        make.centerY.mas_equalTo(textView);
    }];
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(textView.superview).insets(UIEdgeInsetsMake(0, defaultMargin, 25, 8));
    }];
}

- (void)updateControlView:(BOOL)isHost chat:(BOOL)isChating {
    if (isHost) {
        if (![controlView.arrangedSubviews containsObject:voiceButton]) {
            [controlView addArrangedSubview:voiceButton];
        }
        if (![controlView.arrangedSubviews containsObject:earButton]) {
            [controlView addArrangedSubview:earButton];
        }
    } else {
        if (isChating) {
            if (![controlView.arrangedSubviews containsObject:voiceButton]) {
                [controlView addArrangedSubview:voiceButton];
            }
            if (![controlView.arrangedSubviews containsObject:earButton]) {
                [controlView addArrangedSubview:earButton];
            }
        } else {
            [voiceButton removeFromSuperview];
            [earButton removeFromSuperview];
        }
    }
    voiceButton.selected = PanoClientService.service.userService.me.audioStatus == PanoUserAudio_Mute;
    
}

- (void)sendText {
    if ([textView.text isEqualToString:@""]) {
        return;
    }
    [_delegate didSendText:textView.text];
    textView.text = @"";
    [textView resignFirstResponder];
}

- (void)startLoudspeaker {
    loudspeakerButton.selected = !loudspeakerButton.selected;
    [PanoClientService.service.audioService setLoudspeakerStatus:!loudspeakerButton.selected];
}

- (void)enableAudio {
    voiceButton.selected = [_delegate toggleAudio];
}

- (void)showEarMonitorPage {
    [_delegate showEarMonitoringView];
}

- (void)exitChat {
    [_delegate exitChat];
}

- (void)dealloc {
    [self removeNotifications];
}

#pragma mark --
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat keyboardHeight = keyboardSize.height;
    if ([_delegate respondsToSelector:@selector(keyboardWillShow:)]) {
        [_delegate keyboardWillShow:keyboardHeight];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self->sendStackView.hidden = false;
        self->controlView.hidden = true;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [_delegate keyboardWillHide];
    [UIView animateWithDuration:0.3 animations:^{
        self->sendStackView.hidden = true;
        self->controlView.hidden = false;
    }];
}

@end
