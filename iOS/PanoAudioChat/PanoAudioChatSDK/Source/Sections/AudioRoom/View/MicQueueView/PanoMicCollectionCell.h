//
//  PanoMicCollectionCell.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import <UIKit/UIKit.h>
#import "PanoMicInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PanoMicCollectionCellDelegate <NSObject>

- (void)onMicButtonPressed:(PanoMicInfo *)micInfo;

@end


@interface PanoMicCollectionCell : UICollectionViewCell

@property (nonatomic, weak) id <PanoMicCollectionCellDelegate> delegate;

- (void)updateMicInfo:(PanoMicInfo *)info;

@end

NS_ASSUME_NONNULL_END
