//
//  PanoAudioRoomController.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoAudioRoomController.h"
#import "PanoAudioRoomPresenter.h"
#import "PanoNaviTitleView.h"
#import "PanoRoomHeaderView.h"
#import "PanoMicQueueView.h"
#import "PanoAudioRoomPresenter.h"
#import "PanoApplyUserListView.h"
#import "PanoMyApplyView.h"
#import "PanoChatView.h"
#import "PanoAudioPlayerView.h"
#import "PanoEarMonitoring.h"
#import "PanoChatInputView.h"
#import "PanoNaviBadgeView.h"
#import "PanoAudioPanelView.h"
#import "PanoClientService.h"
#import "MBProgressHUD+Extension.h"
#import "PanoInviteListViewController.h"
#import "PanoClientService+OpenApi.h"


@interface PanoAudioRoomController () <PanoAudioRoomInterface,
PanoApplyUserListDelegate,
PanoChatInputViewDelegate>

@end

@implementation PanoAudioRoomController {
    PanoNaviTitleView *naviTitleView;
    
    PanoRoomHeaderView * headerView;
    
    PanoMicQueueView * micQueueView ;
    
    UIImageView * bgImageView;
    
    UIImageView * bgBottomImg;
    
    PanoAudioRoomPresenter * presenter;
    
    PanoApplyUserListView * applyListView;
    
    PanoMyApplyView * myApplyView;
    
    PanoAudioPlayerView * audioPlayerView;
    PanoAudioPanelView * audioPanelView;
    PanoEarMonitoring * earMonitoring;
    PanoChatInputView * chatInputView;
    PanoChatView * chatView;
    UIView * contentView;
    PanoNaviBadgeView * badgeView;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
}

- (void)initViews {
    
    [self setBgView];
    [self setNaviBar];
    
    contentView = [UIView new];
    [self.view addSubview:contentView];
    
    headerView = [[PanoRoomHeaderView alloc] init];
    [contentView addSubview:headerView];
    
    micQueueView = [[PanoMicQueueView alloc] init];
    [contentView addSubview:micQueueView];
    
    // ??????????????????
    applyListView = [[PanoApplyUserListView alloc] initWithFrame:CGRectZero];
    applyListView.delegate = self;
    
    // ????????????
    myApplyView = [[PanoMyApplyView alloc] init];
    
    // ????????????
    
    audioPanelView = [[PanoAudioPanelView alloc] initWithFrame: CGRectMake(0, PanoAppHeight, PanoAppWidth, 100)];
    
    // ????????????
    earMonitoring = [[PanoEarMonitoring alloc] initWithFrame: CGRectMake(0, PanoAppHeight, PanoAppWidth, 100)];
    
    chatInputView = [[PanoChatInputView alloc] init]; // ???????????????
    chatInputView.delegate = self;
    [contentView addSubview:chatInputView];
    
    chatView = [[PanoChatView alloc] init]; // ????????????
    [contentView addSubview:chatView];
    
    audioPlayerView = [[PanoAudioPlayerView alloc] init]; // ???????????????
    audioPlayerView.hidden = true;
    [contentView addSubview:audioPlayerView];
}

- (void)setNaviBar {
    self.navigationItem.leftBarButtonItem = nil;
    UIBarButtonItem *setting = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_setting"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettingPage)];
    UIBarButtonItem *leave = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_leave"] style:UIBarButtonItemStylePlain target:self action:@selector(showLeaveAlert)];
    self.navigationItem.rightBarButtonItems = @[leave, setting];
    __weak typeof(self) weakSelf = self;
    badgeView = [[PanoNaviBadgeView alloc] initWithImage:[UIImage imageNamed:@"room_notice"] operationBlock:^{
        [weakSelf showApplyChatView];
    }];
}

- (void)setBgView {
    bgImageView = [[UIImageView alloc] init];
    bgImageView.image = [UIImage imageNamed:@"room_bg"];
    [self.view addSubview:bgImageView];
}

- (void)initConstraints {
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.view).insets(UIEdgeInsetsMake([self topSafeArea], 0, 0, 0));
        make.height.mas_equalTo(180);
    }];
    
    [micQueueView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(240);
        make.top.mas_equalTo(headerView.mas_bottom);
    }];
    
    [audioPlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0).offset(19);
        make.bottom.mas_equalTo(0).offset(-120);
        make.height.mas_equalTo(39);
    }];
    
    [chatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(micQueueView.mas_bottom).offset(8);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(chatInputView.mas_top).offset(-8);
    }];
    
    [chatInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(60);
    }];
}

- (void)initService {
    
    [self updateNaviTitleView];
    PanoClientConfig * config = PanoClientService.service.config;
    if (!config) {
        return;
    }
    presenter = [[PanoAudioRoomPresenter alloc] initWithUserMode:config.userMode];
    presenter.delegate = self;
    
    micQueueView.delegate = presenter;
    [self reloadMicQueueView];
    __weak typeof(self) weakSelf = self;
    myApplyView->cancelBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf->presenter cancelChat];
        [strongSelf cancelApplyAlert];
    };
    
    audioPlayerView.delegate = presenter;
    
    [self reloadControlView];
    [contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)]];
    
    [chatView start];
    audioPanelView->dismissBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf->audioPlayerView->playBtn.selected = ![PanoClientService.service.playerService isMusicPlaying];
    };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:true];
    [PanoClientService.service joinWithConfigWithCompletion:^(NSError * _Nonnull error) {
        [hud hideAnimated:true];
        if (!error) {
            if (PanoClientService.service.userService.isHost) {
                self->audioPlayerView.hidden = false;
                [self showTips];
            }
            return;
        }
        NSString *msg = NSLocalizedString(@"??????????????????", nil);
        if (error.code == 1) {
            msg = NSLocalizedString(@"??????????????????????????????????????????", nil);
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"??????", nil) style:0 handler:^(UIAlertAction * _Nonnull action) {
            [self dismiss];
        }]];
        [self presentViewController:alert animated:true completion:nil];
        //        [MBProgressHUD showMessage:msg addedToView:self.view duration:3];
    }];
}

- (CGFloat)topSafeArea {
    CGFloat top = panoStatusBarHeight();
    if (self.navigationController != nil) {
        top = top + 44;
    }
    return top;
}

- (void)showTips {
    if (!PanoClientService.service.audioAdvanceProcess) {
        [MBProgressHUD showMessage:NSLocalizedString(@"?????????????????????????????????????????????????????????", nil) addedToView:self.view
                          duration:3];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return  UIStatusBarStyleLightContent;
}

- (void)showSettingPage {
    [self presentViewController:PanoClientService.service.settingViewController animated:true completion:nil];
}

- (void)showLeaveAlert {
    [self showExitRoomActionSheet: presenter->dataSource->myMicInfo.isOnline];
}

// showStopChat default false
- (void)showExitRoomActionSheet:(BOOL)showStopChat {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *title = PanoClientService.service.userService.isHost ? NSLocalizedString(@"?????????????????????", nil) :
    NSLocalizedString(@"????????????", nil);
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:title
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        [self->presenter leaveRoom];
        [self dismiss];
    }];
    UIAlertAction *stopChatAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"????????????", nil)
                                                             style:UIAlertActionStyleDestructive
                                                           handler:^(UIAlertAction * _Nonnull action) {
        [self->presenter stopMyChat];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"??????", nil)
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:ok];
    if (showStopChat) {
        [alert addAction:stopChatAction];
    }
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];
}


#pragma mark -- PanoAudioRoomInterface

- (void)reloadControlView {
    BOOL chating = presenter->dataSource->myMicInfo.isOnline;
    [chatInputView updateControlView:PanoClientService.service.userService.isHost chat:chating];
}

- (void)reloadMicQueueView {
    micQueueView->data = presenter->dataSource.allMics;
    [micQueueView reloadData];
}

- (void)showApplyChatView {
    [applyListView showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)updateApplyChatView:(NSArray <PanoMicInfo *>*)applyUsers {
    if (applyUsers.count > 0) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: badgeView];
        badgeView->badgeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)applyUsers.count];
        applyListView->dataSource = applyUsers;
        [applyListView reloadView];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        [applyListView dismiss];
    }
}

- (void)showApplyAlert:(void(^)(BOOL))handler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:NSLocalizedString(@"????????????" ,nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"??????", nil)
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        handler(true);
        [self->myApplyView showInView:[UIApplication sharedApplication].keyWindow];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"??????", nil)
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)cancelApplyAlert {
    [myApplyView dismiss];
}

- (void)showExitAlert:(NSString *)message handler:(void(^)(BOOL))handler {
    [audioPanelView dismiss];
    if (self.presentedViewController && ![self.presentedViewController isBeingDismissed]) {
        [self.presentedViewController dismissViewControllerAnimated:false completion:nil];
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:NSLocalizedString(@"???????????????" ,nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"??????", nil)
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        [self->presenter leaveRoom];
        [self dismiss];
        handler(true);
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:true completion:nil];
}

// mute default true
- (void)showkickMicActionSheet:(BOOL)mute
                       handler:(void(^)(PanoActionSheetType))handler  {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:nil
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *title = mute ? NSLocalizedString(@"??????", nil):
    NSLocalizedString(@"??????", nil);
    UIAlertAction *ok = [UIAlertAction actionWithTitle:title
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        handler(mute ? PanoActionMuteUser : PanoActionUnmuteUser);
    }];
    [alert addAction:ok];
    UIAlertAction *killUser = [UIAlertAction actionWithTitle:NSLocalizedString(@"????????????", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        handler(PanoActionKillUser);
    }];
    [alert addAction:killUser];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"??????", nil)
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)showInvitePage:(PanoMicInfo *)micInfo {
    PanoInviteListViewController *vc = [[PanoInviteListViewController alloc] init];
    vc.micInfo = micInfo;
    vc.onlineUser = presenter->dataSource.onlineUsers;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:true completion:nil];
}

- (void)updateNaviTitleView {
    NSString *subTitle = [NSString stringWithFormat:@"%zd%@",[PanoClientService.service.userService totalCount], NSLocalizedString(@"?????????", nil)];
    self.navigationItem.titleView = [[[PanoNaviTitleView alloc] initWithTitle:PanoClientService.service.config.roomId subTitle:subTitle] naviTitleView];
}

- (void)updateHeaderView:(PanoUserInfo *)host {
    headerView->nameLabel.text = host.userName;
    [headerView update];
    //    self.view.hideToastActivity()
}

- (void)showInvitedToast {
    [MBProgressHUD showMessage:NSLocalizedString(@"????????????????????????", nil) addedToView:self.view
                      duration:3];
}

- (void)showToast:(NSString *)message {
    [MBProgressHUD showMessage:message addedToView:self.view
                      duration:3];
}

- (void)showInvitedAlert:(NSString *)message handler:(void (^)(BOOL, PanoCmdReason))handler {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:nil
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"??????", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        handler(true, ok);
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"??????", nil)
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction * _Nonnull action) {
        handler(false, ok);
    }];
    [alert addAction:cancel];
    [alert addAction:okAction];
    [self presentViewController:alert animated:true completion:nil];
    __weak UIAlertController *weakAlert = alert;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(PanoMsgExpireInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakAlert != nil) {
            [weakAlert dismissViewControllerAnimated:true completion:nil];
            handler(false, timeout);
        }
    });
}

- (void)showRejectedToast:(NSString *)message {
    [MBProgressHUD showMessage:(message ?: NSLocalizedString(@"???????????????????????????", nil)) addedToView:self.view
                      duration:3];
}

- (void)showAudioPanelView {
    [chatInputView->textView resignFirstResponder];
    [audioPanelView showInView:UIApplication.sharedApplication.keyWindow];
}

#pragma mark -- PanoApplyUserListDelegate

- (void)onClickAcceptButton:(PanoMicInfo *)info {
    [presenter accpetChat:info];
}

- (void)onClickRejectButton:(PanoMicInfo *)info{
    [presenter rejectChat:info reason:ok];
}

#pragma mark -- PanoChatInputViewDelegate

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
}



- (void)didSendText:(NSString *)text {
    [PanoClientService.service.chatService sendTextMessage:text];
}

- (void)keyboardWillShow:(CGFloat)height {
    [UIView animateWithDuration:0.3 animations:^{
        [self.navigationController setNavigationBarHidden:true animated:true];
        self->contentView.transform = CGAffineTransformMakeTranslation(0, -height-pano_safeAreaInset(self.view).bottom);
    }];
}

- (void)keyboardWillHide {
    [UIView animateWithDuration:0.3 animations:^{
        [self.navigationController setNavigationBarHidden:false animated:true];
        self->contentView.transform = CGAffineTransformIdentity;
    }];
}

- (void)showEarMonitoringView {
    [earMonitoring showInView:UIApplication.sharedApplication.keyWindow];
}

- (void)exitChat {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:nil
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"????????????", nil)
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        [self->presenter stopMyChat];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"??????", nil)
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)hideKeyboard {
    [chatInputView->textView resignFirstResponder];
}

- (BOOL)toggleAudio {
    if (presenter->dataSource->myMicInfo.status == PanoMicFinishedMuted) {
        [MBProgressHUD showMessage:NSLocalizedString(@"?????????????????????", nil) addedToView:self.view
                          duration:3];
        return true;
    }
    [PanoClientService.service.audioService toggleAudio];
    return PanoClientService.service.audioService.isMuted;
}

@end
