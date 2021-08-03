//
//  PanoMicQueueView.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoBaseView.h"
#import "PanoMicCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PanoMicQueueView : PanoBaseView <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    @package
    NSArray <PanoMicInfo *> *data;
}

@property(nonatomic, weak) id <PanoMicCollectionCellDelegate> delegate;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
