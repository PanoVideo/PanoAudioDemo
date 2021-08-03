//
//  PanoAudioPanelView.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/20.
//

#import <Foundation/Foundation.h>
#import "PanoBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PanoAudioPanelView : PanoBaseView
{
    @package
    void(^dismissBlock)(void);
}

- (void)showInView:(UIView *)parentView;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
