//
//  PanoAudioPanelView.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/20.
//

#import "PanoAudioPanelView.h"
#import "PanoAudioVolume.h"
#import "PanoDefine.h"
#import "PanoClientService.h"

@implementation PanoAudioPanelView
{
    PanoAudioVolume *musicVolumeView;
    
    PanoAudioVolume *effectVolumeView;
    
    UIView *contentView;
    
    UIView *coverView;
    
    UILabel *musicTitleLabel;
    
    UILabel *effectTitleLabel;
    
    UIView *lineView;
    
    UIStackView *musicView;
    
    UIStackView *effectAudioView;
    
    UIStackView *effectAudioView2;
    
    NSMutableArray<NSString *> *dataSource;
    
    __weak PanoPlayerService *playerService;
}

- (void)initViews  {
    
    playerService = PanoClientService.service.playerService;
    
    coverView = [UIView new];
    coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
    [self addSubview:coverView];
    
    contentView = [UIView new];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 10;
    contentView.layer.masksToBounds = true;
    [self addSubview:contentView];
    
    musicTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PanoAppWidth, 50)];
    musicTitleLabel.text = NSLocalizedString(@"背景音乐", nil);
    musicTitleLabel.textColor = defaultTextColor();
    musicTitleLabel.textAlignment = NSTextAlignmentCenter;
    musicTitleLabel.font = fontLarger();
    [contentView addSubview:musicTitleLabel];
    
    musicView = [UIStackView new];
    musicView.axis = UILayoutConstraintAxisHorizontal;
    musicView.distribution = UIStackViewDistributionFillEqually;
    musicView.spacing = 30;
    [contentView addSubview:musicView];
    
    NSArray *audios = playerService.audioNames;
    for (NSInteger i=0; i<audios.count; i++) {
        NSString *title = audios[i] ?: @"";
        UIButton *button = [self createMusicButton: NSLocalizedString(title, nil) image:nil];
        button.tag = i;
        [button addTarget:self action:@selector(chooseMusicAction:) forControlEvents:UIControlEventTouchUpInside];
        [musicView addArrangedSubview:button];
    }
    
    musicVolumeView = [[PanoAudioVolume alloc] init];
    musicVolumeView->slider.maximumValue = 200;
    musicVolumeView->slider.value = 100;
    [musicVolumeView->slider addTarget:self action:@selector(musicVolumeChanged:) forControlEvents:UIControlEventValueChanged];
    [contentView addSubview:musicVolumeView];
    
    lineView = [UIView new];
    lineView.backgroundColor = defaultBorderColor();
    [contentView addSubview:lineView];
    
    effectTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PanoAppWidth, 50)];
    effectTitleLabel.text = NSLocalizedString(@"声效", nil);
    effectTitleLabel.textColor = defaultTextColor();
    effectTitleLabel.textAlignment = NSTextAlignmentCenter;
    effectTitleLabel.font = fontLarger();
    [contentView addSubview:effectTitleLabel];
    
    effectAudioView = [UIStackView new];
    effectAudioView.axis = UILayoutConstraintAxisHorizontal;
    effectAudioView.distribution = UIStackViewDistributionFillEqually;
    effectAudioView.spacing = 30;
    [contentView addSubview:effectAudioView];
    
    effectAudioView2 = [UIStackView new];
    effectAudioView2.axis = UILayoutConstraintAxisHorizontal;
    effectAudioView2.distribution = UIStackViewDistributionFillEqually;
    effectAudioView2.spacing = 30;
    [contentView addSubview:effectAudioView2];
    NSArray *sounds = playerService.soundNames;
    for (NSInteger i=0; i<3; i++) {
        NSString *title = sounds[i] ?: @"";
        UIButton *button = [self createMusicButton: NSLocalizedString(title, nil) image:nil];
        button.tag = i;
        [button addTarget:self action:@selector(chooseSoundEffectAction:) forControlEvents:UIControlEventTouchUpInside];
        [effectAudioView addArrangedSubview:button];
    }
    for (NSInteger j=3; j<sounds.count; j++) {
        NSString *title = sounds[j] ?: @"";
        UIButton *button = [self createMusicButton: NSLocalizedString(title, nil) image:nil];
        [button addTarget:self action:@selector(chooseSoundEffectAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = j;
        [effectAudioView2 addArrangedSubview:button];
    }
    
    
    effectVolumeView = [[PanoAudioVolume alloc] init];
    [effectVolumeView->slider addTarget:self action:@selector(soundEffectVolumeChanged:) forControlEvents:UIControlEventValueChanged];
    effectVolumeView->slider.value = 120;
    [contentView addSubview:effectVolumeView];
}

- (UIButton *)createMusicButton:(NSString *)title image:(UIImage *)image {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState: UIControlStateNormal];
    [button setImage:image forState: UIControlStateNormal];
    [button setImage:image forState: UIControlStateHighlighted];
    [button setTitleColor: defaultTextColor() forState:UIControlStateNormal];
    [button setTitleColor: [UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setTitleColor: [UIColor whiteColor] forState:UIControlStateSelected];
    [button setBackgroundImage:[UIImage pano_imageWithColor:UIColor.whiteColor] forState: UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"home_bg_blue"] forState: UIControlStateSelected];
    [button setBackgroundImage:[UIImage imageNamed:@"home_bg_blue"] forState: UIControlStateHighlighted];
    button.layer.cornerRadius = 8;
    button.layer.masksToBounds = true;
    button.layer.borderColor = defaultBorderColor().CGColor;
    button.layer.borderWidth = 0.8;
    return button;
}

- (void)chooseMusicAction:(UIButton *)sender {
    NSString *title = playerService.audioNames[sender.tag];
    if (title) {
        if ([playerService.activeAudioName isEqualToString:title]) {
            [playerService stopAudioMixingTask:title];
        } else {
            [playerService startAudioMixingTask:title withVolume:(UInt32)musicVolumeView->slider.value];
        }
        [self updateMusicButtonStatus];
    }
}

- (void)chooseSoundEffectAction:(UIButton *)sender {
    NSString *title = playerService.soundNames[sender.tag];
    if (title) {
        [playerService startSoundEffectTask:title withVolume:(UInt32)effectVolumeView->slider.value];
    }
}

- (void)initConstraints  {
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(contentView.mas_top);
    }];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(420);
        make.bottom.mas_equalTo(0).offset(5);
    }];
    
    [musicTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(60);
    }];
    
    UIEdgeInsets insets = UIEdgeInsetsMake( 0, 30, 0, 30);
    [musicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0).insets(insets);
        make.top.mas_equalTo(musicTitleLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(40);
    }];
    
    [musicVolumeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(musicView.mas_bottom).offset(10);
        make.height.mas_equalTo(50);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0).insets(UIEdgeInsetsMake(0, defaultMargin,0, defaultMargin));
        make.top.mas_equalTo(musicVolumeView.mas_bottom);
        make.height.mas_equalTo(0.8);
    }];
    
    [effectTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(lineView.mas_bottom);
        make.height.mas_equalTo(60);
    }];
    
    [effectAudioView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0).insets(insets);
        make.top.mas_equalTo(effectTitleLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(40);
    }];
    
    [effectAudioView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0).insets(insets);
        make.top.mas_equalTo(effectAudioView.mas_bottom).offset(10);
        make.height.mas_equalTo(40);
    }];
    
    [effectVolumeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(effectAudioView2.mas_bottom).offset(10);
        make.height.mas_equalTo(50);
    }];
}

- (void)showInView:(UIView *)parentView {
    if (![parentView.subviews containsObject:self]) {
        [parentView addSubview:self];
    }
    self.alpha = 0.1;
    CGRect frame = parentView.frame;
    frame.origin.y = frame.size.height;
    self.frame = frame;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }];
    [self updateMusicButtonStatus];
}

- (void)updateMusicButtonStatus {
    NSUInteger index = [playerService.audioNames indexOfObject:playerService.activeAudioName];
    for (NSInteger i=0; i<musicView.subviews.count; i++) {
        UIButton *view = musicView.subviews[i];
        view.selected = i == index;
    }
}

- (void)dismiss  {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.1;
        self.frame = CGRectMake(0, PanoAppHeight,  PanoAppWidth, PanoAppHeight);
        [self removeFromSuperview];
        if (self->dismissBlock != nil) {
            self->dismissBlock();
        }
    }];
}

- (void)musicVolumeChanged:(UISlider *)slider {
    [playerService updateVolume:(UInt32)slider.value];
}

- (void)soundEffectVolumeChanged:(UISlider *)slider {
    
}

@end
