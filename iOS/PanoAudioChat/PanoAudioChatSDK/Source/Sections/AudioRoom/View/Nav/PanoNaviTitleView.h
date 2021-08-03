//
//  PanoNaviTitleView.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PanoNaviTitleView : NSObject

- (instancetype)initWithTitle:(NSString *)title
                    subTitle:(NSString *)subTitle;

- (UIView *)naviTitleView;

@end

NS_ASSUME_NONNULL_END
