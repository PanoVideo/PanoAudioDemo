//
//  PanoAudioVolume.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoAudioVolume.h"

@implementation PanoAudioVolume {
    UIImageView *icon;
}

- (void)initViews {
    icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"room_loudspeaker_black"]];
    [self addSubview:icon];
    
    slider = [[UISlider alloc] init];
    slider.minimumValue = 0;
    slider.maximumValue = 200;
    slider.value = 50;
    [self addSubview:slider];
}

- (void)initConstraints {
    
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0).offset(30);
        make.centerY.mas_equalTo(0);
    }];
    
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.equalTo(icon.mas_right).offset(defaultMargin);
        make.right.mas_equalTo(0).offset(-30);
    }];
}
@end
