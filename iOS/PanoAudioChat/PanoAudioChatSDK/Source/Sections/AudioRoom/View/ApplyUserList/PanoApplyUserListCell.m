//
//  PanoApplyUserListCell.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoApplyUserListCell.h"
#import "PanoDefine.h"
#import <Masonry/Masonry.h>



@implementation PanoApplyUserListCell {
    UIButton *acceptBtn;
    UIButton *rejectBtn;
    UIView *lineView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    lineView = [UIView new];
    lineView.backgroundColor = defaultBorderColor();
    [self.contentView addSubview:lineView];
    
    nameLabel = [UILabel new];
    nameLabel.font = fontMedium();
    nameLabel.textColor = defaultTextColor();
    [self.contentView addSubview:nameLabel];
    
    acceptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [acceptBtn setTitle:NSLocalizedString(@"允许", nil) forState: UIControlStateNormal];
    acceptBtn.titleLabel.textColor = [UIColor whiteColor];
    [acceptBtn setBackgroundImage:[UIImage imageNamed:@"home_bg_blue"] forState: UIControlStateNormal];
    [acceptBtn setBackgroundImage:[UIImage imageNamed:@"home_bg_blue"] forState: UIControlStateHighlighted];
    [acceptBtn addTarget:self action:@selector(accept:) forControlEvents:UIControlEventTouchUpInside];
    acceptBtn.layer.masksToBounds = true;
    acceptBtn.layer.cornerRadius = 15.0;
    [self.contentView addSubview:acceptBtn];
    
    rejectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rejectBtn setTitle:NSLocalizedString(@"拒绝", nil) forState: UIControlStateNormal];
    [rejectBtn setTitleColor:defaultTextColor() forState:UIControlStateNormal];
    [rejectBtn setTitleColor:defaultTextColor() forState:UIControlStateHighlighted];
    [rejectBtn addTarget:self action:@selector(reject:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:rejectBtn];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0).insets(UIEdgeInsetsMake(0, 0, 0.8, 0));
        make.height.mas_equalTo(0.8);
    }];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(0).offset(defaultMargin);
        make.right.mas_equalTo(rejectBtn.mas_left).offset(-defaultMargin);
    }];
    
    [acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(0).offset(-defaultMargin);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(84);
    }];
    
    [rejectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(acceptBtn.mas_left).offset(-defaultMargin);
        make.height.mas_equalTo(acceptBtn);
        make.width.mas_equalTo(acceptBtn);
    }];
    return self;
}

- (void)accept:(UIButton *)sender {
    acceptBlock();
}

- (void)reject:(UIButton *)sender {
    rejectBlock();
}

@end
