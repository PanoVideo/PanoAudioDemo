//
//  PanoTextField.m
//  PanoAudioChat
//
//  Created by pano on 2021/7/20.
//

#import "PanoTextField.h"
#import "PanoDefine.h"
#import <Masonry/Masonry.h>

@implementation PanoTextField {
    UIView *contentView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    contentView = [UIView new];
    [self addSubview:contentView];
    
    leftLabel = [UILabel new];
    leftLabel.textColor = defaultTextColor();
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.font = [UIFont systemFontOfSize:14];
    [contentView addSubview:leftLabel];
    
    textfiled = [[UITextField alloc] init];
    textfiled.layer.cornerRadius = 20;
    textfiled.layer.masksToBounds = true;
    textfiled.layer.borderColor = defaultBorderColor().CGColor;
    textfiled.layer.borderWidth = 1;
    textfiled.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, DefaultViewHeight)];
    textfiled.leftViewMode = UITextFieldViewModeAlways;
    [contentView addSubview:textfiled];
}

- (void)initConstraints {
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.mas_equalTo(0);
        make.width.mas_equalTo(60);
        make.right.equalTo(textfiled.mas_left).offset(-20);
    }];
    
    [textfiled mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.mas_equalTo(0);
            make.height.mas_equalTo(DefaultViewHeight);
    }];
}

@end
