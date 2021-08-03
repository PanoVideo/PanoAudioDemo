//
//  PanoNaviTitleView.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoNaviTitleView.h"
#import "PanoDefine.h"

@implementation PanoNaviTitleView {
    NSString *title;
    NSString *subTitle;
}

- (instancetype)initWithTitle:(NSString *)title
                    subTitle:(NSString *)subTitle {
    self = [super init];
    if (self) {
        self->title =title;
        self->subTitle = subTitle;
    }
    return self;
}

- (UIView *)naviTitleView {
    UILabel *titleView = [UILabel new];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.numberOfLines = 0;
    UIColor *whiteColor = [UIColor whiteColor];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:title attributes:@{
        NSForegroundColorAttributeName : whiteColor,
        NSFontAttributeName: fontLarger()
    }];
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    NSAttributedString *subStr = [[NSAttributedString alloc] initWithString:subTitle attributes:@{
        NSForegroundColorAttributeName : whiteColor,
        NSFontAttributeName: fontMin()
    }];
    [attrStr appendAttributedString:subStr];
    titleView.attributedText = attrStr;
    return titleView;
}

@end
