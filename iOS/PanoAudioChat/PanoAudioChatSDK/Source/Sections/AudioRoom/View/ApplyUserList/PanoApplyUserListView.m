//
//  PanoApplyUserListView.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoApplyUserListView.h"
#import "PanoApplyUserListCell.h"
#import "PanoDefine.h"
#import "PanoMicInfo.h"
#import "PanoApplyAlertView.h"

#define headerHeight (isIphoneX() ? 44 : 20)

@interface PanoApplyUserListView () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation PanoApplyUserListView
{
    UIView *coverView;
    UITableView *tableView;
    PanoApplyAlertView *footerView;
    UIView *headerView;
    BOOL isShowListView;
}
   
    
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    coverView = [UIView new];;
    self.userInteractionEnabled = true;
    self.frame = CGRectMake(0.0, 0, UIScreen.mainScreen.bounds.size.width, 0.0);
    footerView = [[PanoApplyAlertView alloc] initWithFrame:CGRectMake(0.0, 0, UIScreen.mainScreen.bounds.size.width, 35.0)];
    [footerView->countBtn addTarget:self action:@selector(showListView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:footerView];
    tableView = [[UITableView alloc] init];
    [tableView registerClass:[PanoApplyUserListCell class] forCellReuseIdentifier:@"cellID"];
    tableView.tableFooterView = [UIView new];
    tableView.showsVerticalScrollIndicator = false;
    tableView.showsHorizontalScrollIndicator = false;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.allowsSelection = false;
    [self addSubview:tableView];
    self.backgroundColor = [UIColor whiteColor];
}
    
- (void)initConstraints {
    [tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0).insets(UIEdgeInsetsMake(headerHeight, 0, 0, 0));
    }];
    
    [footerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(35);
        make.top.mas_equalTo(tableView.mas_bottom);
    }];
}


#pragma mark -- Extension
- (void)showListView {
    if (isShowListView) {
        [self dismissListView];
        return;
    }
    isShowListView = true;
    [self reloadView];
}

- (void)dismissListView {
    if (!isShowListView) {
        return;
    }
    isShowListView = false;
    [self dismiss];
}

- (void)reloadView {
    NSUInteger maxCount  = dataSource.count >= 4 ? 4 : dataSource.count;
    CGFloat height = headerHeight + 60 * maxCount + 35.0;
    self.frame = CGRectMake(0.0, 0, UIScreen.mainScreen.bounds.size.width, height);
    [tableView reloadData];
}

- (void)showInView:(UIView *)parentView {
    if (dataSource.count == 0) {
        [self dismiss];
        return;
    }
    if (![parentView.subviews containsObject:self]) {
        coverView.frame = parentView.bounds;
        coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissListView)]];
        [parentView addSubview:coverView];
        coverView.alpha = 0.01;
        [parentView addSubview:self];
    }
    
    self.alpha = 0.1;
    self.frame = CGRectMake(0, -PanoAppHeight, PanoAppWidth,  PanoAppHeight);
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 1;
        self->coverView.alpha = 1;
        self.frame = CGRectMake(0, 0, PanoAppWidth,  PanoAppHeight);
    }];
    
    footerView->countLabel.text = [NSString stringWithFormat:@"%zd",dataSource.count];
    [self showListView];
}

- (void)dismiss {
    if (self.superview == nil) {
        return;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.1;
        self->coverView.alpha = 0.1;
        self.frame = CGRectMake(0, -PanoAppHeight, PanoAppWidth,  0);
    } completion:^(BOOL finished) {
        [self->coverView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

#pragma mark -- UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  {
    return dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PanoApplyUserListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    PanoMicInfo * micInfo = [self cellForUserInfo:indexPath];
    cell->nameLabel.text = [NSString stringWithFormat:@"'%@' %@", micInfo.user.userName ? micInfo.user.userName : NSLocalizedString(@"未知", nil), NSLocalizedString(@"正在申请上麦", nil)];
    cell->acceptBlock = ^{
        [self dismissListView];
        [self.delegate onClickAcceptButton:micInfo];
    };
    cell->rejectBlock = ^{
        [self dismissListView];
        [self.delegate onClickRejectButton:micInfo];
    };
    return cell;
}

- (PanoMicInfo *)cellForUserInfo:(NSIndexPath *)indexPath {
    if (indexPath.row < dataSource.count) {
        return dataSource[indexPath.row];
    }
    return nil;
}

@end
