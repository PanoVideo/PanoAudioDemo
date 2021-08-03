//
//  PanoNaviBadgeView.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoNaviBadgeView.h"

@implementation PanoNaviBadgeView
{
    UIButton *button;
    UIImage *buttonImage;
    void(^block)(void);
}

- (instancetype)initWithImage:(UIImage *)image
               operationBlock:(void(^)(void))block {
    self = [super init];
    if (self) {
        buttonImage = image;
        self->block = block;
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 30, 30);
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setImage:buttonImage forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    badgeLabel = [UILabel new];
    badgeLabel.textColor = [UIColor whiteColor];
    badgeLabel.backgroundColor = [UIColor redColor];
    badgeLabel.font = fontLittle();
    badgeLabel.layer.cornerRadius = 7.5;
    badgeLabel.layer.masksToBounds = true;
    badgeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:badgeLabel];
}

- (void)initConstraints {
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    [badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(button).offset(10.6);
        make.centerY.equalTo(button).offset(-10.6);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
}

- (void)clickAction {
    self->block();
}

@end
