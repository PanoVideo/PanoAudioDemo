//
//  PanoRoomHeaderView.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PanoRoomHeaderView : PanoBaseView {
    @package
    UILabel *nameLabel;
}

- (void)update;

@end

NS_ASSUME_NONNULL_END
