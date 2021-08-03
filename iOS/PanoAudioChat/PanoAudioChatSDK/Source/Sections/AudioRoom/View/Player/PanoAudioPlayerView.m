//
//  PanoAudioPlayerView.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoAudioPlayerView.h"

@implementation PanoAudioPlayerView
{
    UIView *contentView;

    UIButton *nextBtn;

    UIImageView *icon;
}

- (void)initViews {
    contentView = [UIView new];
    contentView.layer.masksToBounds = true;
    contentView.layer.cornerRadius = 19;
    contentView.backgroundColor = [UIColor pano_colorWithHexString:@"#577096"];
    [self addSubview:contentView];
    
    icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"room_player_music"]];
    [contentView addSubview:icon];
    
    playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [playBtn setImage:[UIImage imageNamed:@"room_player_pause"] forState:UIControlStateNormal];
    [playBtn setImage:[UIImage imageNamed:@"room_player_play"] forState:UIControlStateSelected];
    playBtn.selected = true;
    [playBtn addTarget:self action:@selector(didStartPlayAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:playBtn];
    
    nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setImage:[UIImage imageNamed:@"room_player_next"] forState:UIControlStateNormal];
    [nextBtn setImage:[UIImage imageNamed:@"room_player_next"] forState:UIControlStateSelected];
    [nextBtn addTarget:self action:@selector(didChooseNextAction) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:nextBtn];
  
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMoreAction)]];
}

- (void)initConstraints {
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(120);
        make.edges.mas_equalTo(0);
    }];
    
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(0).mas_offset(3);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(icon.mas_right).offset(5);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(playBtn.mas_right).offset(5);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
}

- (void)didStartPlayAction:(BOOL)pause {
    playBtn.selected = !playBtn.selected;
    [_delegate didStartPlayAction:playBtn.isSelected];
}

- (void)didChooseNextAction {
    playBtn.selected = false;
    [_delegate didChooseNextAction];
}

- (void)showMoreAction {
    [_delegate didShowMoreAction];
}


@end
