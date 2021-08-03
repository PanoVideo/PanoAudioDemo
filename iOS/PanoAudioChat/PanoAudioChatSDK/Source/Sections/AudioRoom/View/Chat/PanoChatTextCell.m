//
//  PanoChatTextCell.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoChatTextCell.h"
#import "PanoDefine.h"
#import <Masonry/Masonry.h>

@implementation PanoChatTextCell {
    UIView *wrapView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier: reuseIdentifier];
    if (self) {
        wrapView = [UIView new];
        wrapView.layer.cornerRadius = 5;
        wrapView.layer.masksToBounds = true;
        [self.contentView addSubview:wrapView];
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];

        contentLabel = [UILabel new];
        contentLabel.font = fontMedium();
        contentLabel.textColor = [UIColor whiteColor];
        contentLabel.numberOfLines = 0;
        [wrapView addSubview:contentLabel];
        
        [wrapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView).insets(UIEdgeInsetsMake(0, defaultMargin, 0, defaultMargin));
        }];
        
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self->wrapView).insets(UIEdgeInsetsMake(8, 8, 8, 8));
        }];
    }
    return self;
}

@end
