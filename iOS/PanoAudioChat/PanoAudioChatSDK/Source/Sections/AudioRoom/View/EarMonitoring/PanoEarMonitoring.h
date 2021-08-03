//
//  PanoChatView.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PanoEarMonitoring : PanoBaseView

- (void)showInView:(UIView *)parentView;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
