//
//  PanoUserListCell.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/16.
//

#import "PanoUserListCell.h"
#import "PanoDefine.h"
#import <Masonry/Masonry.h>

@implementation PanoUserListCell {
    UIImageView *avator;
    UIButton *chooseButton;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        nameLabel = [UILabel new];
        nameLabel.font = fontMax();
        [self.contentView addSubview:nameLabel];
        avator = [UIImageView new];
        avator.image = [UIImage imageNamed:@"room_avator"];
        [self.contentView addSubview:avator];
        
        [avator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(35, 35));
            make.centerY.mas_equalTo(self.contentView);
            make.left.mas_equalTo(self.contentView).offset(defaultMargin);
        }];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.centerY.mas_equalTo(self.contentView);
            make.height.mas_equalTo(30);
            make.left.mas_equalTo(avator.mas_right).offset(defaultMargin);
        }];
    }
    return self;
}

@end
