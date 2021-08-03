//
//  PanoMyApplyView.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoMyApplyView.h"
#import "PanoDefine.h"

@implementation PanoMyApplyView
{
    UILabel *nameLabel;

    UIButton *cancelBtn;
}

- (void)initViews {
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = true;
    
    self.backgroundColor = [UIColor whiteColor];
    nameLabel = [UILabel new];
    nameLabel.font = fontMedium();
    nameLabel.textColor = defaultTextColor();
    nameLabel.text = NSLocalizedString(@"已申请上麦，等候通过···",  nil);
    [nameLabel sizeToFit];
    [self addSubview:nameLabel];
    
    cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState: UIControlStateNormal];
    
    [cancelBtn setTitleColor:[UIColor pano_colorWithHexString:@"#69B4F9"] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor pano_colorWithHexString:@"#69B4F9"] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(cancelApplyChat) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn sizeToFit];
    [self addSubview:cancelBtn];
}

- (void)initConstraints {
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.bottom.mas_equalTo(0).insets(UIEdgeInsetsMake(0, 8, 8, 0));
        make.right.equalTo(cancelBtn.mas_left).offset(-defaultMargin);
    }];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0).offset(-defaultMargin);
        make.centerY.equalTo(nameLabel);
    }];
}

- (void)showInView:(UIView*)view {
    [view addSubview:self];
    CGFloat viewHeight = (isIphoneX() ? 44 : 20) + 40;
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.equalTo(view.mas_top);
        make.height.mas_equalTo(viewHeight);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, viewHeight);
    }];

}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)cancelApplyChat {
    cancelBlock();
}


@end
