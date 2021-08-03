//
//  PanoApplyUserListCell.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PanoApplyButtonClosure)(void);

@interface PanoApplyUserListCell : UITableViewCell
{
    @package
    UILabel *nameLabel;
    PanoApplyButtonClosure acceptBlock;
    PanoApplyButtonClosure rejectBlock;
}
@end

NS_ASSUME_NONNULL_END
