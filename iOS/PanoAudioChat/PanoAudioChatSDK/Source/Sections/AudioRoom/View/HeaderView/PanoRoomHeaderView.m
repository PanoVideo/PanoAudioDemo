//
//  PanoRoomHeaderView.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoRoomHeaderView.h"
#import "PanoMicButton.h"
#import "PanoDefine.h"
#import "PanoClientService.h"

CGFloat iconWidth = 85;

@implementation PanoRoomHeaderView {
    PanoMicButton *icon;
}

- (void)initViews {
    nameLabel = [UILabel new];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = fontMedium();
    [self addSubview:nameLabel];
    
    icon = [[PanoMicButton alloc] init];
    PanoUserService *userService = PanoClientService.service.userService;
    if ([userService isHost]) {
        UIImage *image = [userService avatorImage:PanoClientService.service.userId];
        [icon setImage:image forState:UIControlStateNormal];
        [icon setImage:image forState:UIControlStateHighlighted];
    }
    [self addSubview:icon];
}

- (void)initConstraints {
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self).offset(-10);
        make.size.mas_equalTo(CGSizeMake(iconWidth, iconWidth));
    }];

    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(icon.mas_bottom).mas_offset(defaultMargin);
        make.centerX.mas_equalTo(self);
        make.left.right.mas_equalTo(self).insets(UIEdgeInsetsMake(0, defaultMargin, 0, defaultMargin));
    }];
}

- (void)update {
    PanoUserInfo *user = PanoClientService.service.userService.host;
    if (user) {
        UIImage *image = [user avatorImage];
        [icon setImage:image forState:UIControlStateNormal];
        [icon setImage:image forState:UIControlStateHighlighted];
        if (user.isActiving) {
            [icon startAnimating];
        } else {
            [icon stopAnimating];
        }
    }
}

@end
