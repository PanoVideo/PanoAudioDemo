//
//  PanoMyApplyView.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PanoMyApplyView : PanoBaseView
{
    @package
    void(^cancelBlock)(void);
}

- (void)showInView:(UIView*)view;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
