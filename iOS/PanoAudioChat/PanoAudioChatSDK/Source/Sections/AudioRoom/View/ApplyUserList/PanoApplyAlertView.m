//
//  PanoApplyAlertView.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoApplyAlertView.h"
#import "UIColor+Extension.h"
#import "UIImage+Extension.h"

@implementation PanoApplyAlertView {
    UIView *contentView;
}

- (void)initViews {
    
    self.backgroundColor = [UIColor clearColor];
    countBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage pano_imageWithColor:[UIColor pano_colorWithHexString:@"#EC2C2C"]];
    
    [countBtn setBackgroundImage:image forState: UIControlStateNormal];
    [countBtn setBackgroundImage:image forState: UIControlStateNormal];
    countBtn.layer.masksToBounds = true;
    countBtn.layer.cornerRadius = 12.5;
    
    countLabel = [UILabel new];
    countLabel.textColor = [UIColor whiteColor];
    countLabel.textAlignment = NSTextAlignmentCenter;
    [countBtn addSubview:countLabel];
    
    [self addSubview:countBtn];
}

- (void)layoutSubviews{
    [super layoutSubviews];
}
    
- (void)initConstraints {

    [countBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

@end
