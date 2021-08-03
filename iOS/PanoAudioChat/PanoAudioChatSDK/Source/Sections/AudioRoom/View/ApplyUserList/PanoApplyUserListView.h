//
//  PanoApplyUserListView.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import <UIKit/UIKit.h>
#import "PanoMicInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PanoApplyUserListDelegate <NSObject>

- (void)onClickAcceptButton:(PanoMicInfo *)info;

- (void)onClickRejectButton:(PanoMicInfo *)info;

@end

@interface PanoApplyUserListView : UIControl {
    @package
    NSArray<PanoMicInfo *> * dataSource;
}

@property (nonatomic, weak) id <PanoApplyUserListDelegate> delegate;

- (void)showInView:(UIView *)parentView;

- (void)reloadView;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
