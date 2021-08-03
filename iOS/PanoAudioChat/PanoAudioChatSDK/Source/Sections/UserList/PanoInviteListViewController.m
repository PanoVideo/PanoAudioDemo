//
//  PanoInviteListViewController.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/16.
//

#import "PanoInviteListViewController.h"
#import "PanoMicInfo.h"
#import "PanoUserListCell.h"
#import <Masonry/Masonry.h>


@interface PanoInviteListViewController ()<UITableViewDataSource, UITableViewDelegate, PanoUserDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation PanoInviteListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [PanoClientService.service.userService addDelegate:self];
}


- (void)initViews {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_tableView registerClass:[PanoUserListCell class] forCellReuseIdentifier:@"cellID"];
    _tableView.tableFooterView = [UIView new];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = 55;
    [self.view addSubview: _tableView];
    self.title = NSLocalizedString(@"选择成员", nil);
}

- (void)initConstraints {
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

- (void)initService {
    _dataSource = [NSMutableArray array];
    [self reloadViews];
}

- (void)reloadViews {
    [_dataSource removeAllObjects];
    for (PanoUserInfo *user in [PanoClientService.service.userService allUserExceptMe]) {
        if (![self.onlineUser containsObject:user]) {
            [_dataSource addObject:user];
        }
    }
    [_tableView reloadData];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PanoUserListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    PanoUserInfo *info = [self cellForUserInfo:indexPath];
    if (info) {
        cell->nameLabel.text = info.userName;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    PanoUserInfo *user = [self cellForUserInfo:indexPath];
    if (user) {
        _micInfo.userId = user.userId;
        [PanoClientService.service.signalService sendInviteMsg:_micInfo];
        [self dismiss];
    }
}

- (PanoUserInfo *)cellForUserInfo:(NSIndexPath *)indexPath {
    if (indexPath.row < _dataSource.count) {
        return _dataSource[indexPath.row];
    }
    return nil;
}

- (void)onUserAdded:(PanoUserInfo *)user {
    [self reloadViews];
}

- (void)onUserRemoved:(PanoUserInfo *)user {
    [self reloadViews];
}

- (void)dealloc {
    [PanoClientService.service.userService removeDelegate:self];
}

@end
