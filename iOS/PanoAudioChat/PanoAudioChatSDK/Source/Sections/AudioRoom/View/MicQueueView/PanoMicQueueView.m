//
//  PanoMicQueueView.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoMicQueueView.h"
#import "PanoMicInfo.h"
#import "PanoMicCollectionCell.h"

CGFloat InteritemSpacing  = 25;
CGFloat LineSpacing = 30;
CGFloat MarginSpacing = 30;

@interface PanoMicQueueView () <UICollectionViewDataSource,
                                UICollectionViewDelegateFlowLayout>
@end

@implementation PanoMicQueueView {

    UICollectionView *collectionView;

    UICollectionViewFlowLayout *layout;
}



- (void)initViews {
    
    layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0.1;
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsVerticalScrollIndicator = false;
    collectionView.showsHorizontalScrollIndicator = false;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.bounces = false;
    collectionView.clipsToBounds = false;
    [collectionView registerClass:[PanoMicCollectionCell class] forCellWithReuseIdentifier:@"cellID"];
    [self addSubview:collectionView];
}

- (void)initConstraints {
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0).insets(UIEdgeInsetsMake(0, MarginSpacing, 0, MarginSpacing));
    }];
}

- (void)reloadData {
    [collectionView reloadData];
}

- (CGSize)cellSize {
    CGFloat width = (PanoAppWidth - 3 * LineSpacing - 2 * MarginSpacing) / 4;
    if (width > 75) {
        width = 75;
    }
    CGFloat height = width + 30;
    return CGSizeMake(width, height);
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return data.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PanoMicCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    cell.delegate = _delegate;
    [cell updateMicInfo: data[indexPath.row]];
    return cell;
}

#pragma mark -- UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self cellSize];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return LineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return MarginSpacing;
}

@end
