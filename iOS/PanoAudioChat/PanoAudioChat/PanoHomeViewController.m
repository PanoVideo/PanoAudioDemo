//
//  PanoHomeViewController.m
//  PanoAudioChat
//
//  Created by pano on 2021/7/20.
//

#import "PanoHomeViewController.h"
#import <Masonry/Masonry.h>
#import "PanoClientConfig.h"
#import "PanoDefine.h"
#import "PanoJoinViewController.h"
#import "PanoInterface.h"

@interface PanoHomeViewController ()

@end

@implementation PanoHomeViewController {
    UIView *contentView;

    UIButton *createAudioRoomBtn;

    UIButton *settingBtn;

    UIButton *joinAudioRoomBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self initConstraints];
    [self initService];
}

- (void)initViews {
    
    settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingBtn addTarget:self action:@selector(showSettingPage) forControlEvents:UIControlEventTouchUpInside];
    [settingBtn setImage:[UIImage imageNamed:@"btn.setting.black"] forState: UIControlStateNormal];
    [settingBtn setImage:[UIImage imageNamed:@"btn.setting.black"] forState: UIControlStateHighlighted];
    [self.view addSubview:settingBtn];
    
    contentView = [UIView new];
    [self.view addSubview:contentView];
    
    createAudioRoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [createAudioRoomBtn addTarget:self action:@selector(createRoomAction) forControlEvents:UIControlEventTouchUpInside];
    [createAudioRoomBtn setTitle:NSLocalizedString(@"Create a chat room", nil) forState:UIControlStateNormal];
    createAudioRoomBtn.titleLabel.font = fontMax();
    [createAudioRoomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [createAudioRoomBtn setBackgroundImage:[UIImage imageNamed:@"home_bg_yellow"] forState: UIControlStateNormal];
    [createAudioRoomBtn setBackgroundImage:[UIImage imageNamed:@"home_bg_yellow"] forState: UIControlStateHighlighted];
    createAudioRoomBtn.layer.cornerRadius = 8;
    createAudioRoomBtn.layer.masksToBounds = true;
    [contentView addSubview:createAudioRoomBtn];
    
    joinAudioRoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [joinAudioRoomBtn addTarget:self action:@selector(joinRoomAction) forControlEvents:UIControlEventTouchUpInside];
    [joinAudioRoomBtn setTitle:NSLocalizedString(@"Join the chat room", nil) forState:UIControlStateNormal];
    joinAudioRoomBtn.titleLabel.font = fontMax();
    [joinAudioRoomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [joinAudioRoomBtn setBackgroundImage:[UIImage imageNamed:@"home_bg_blue"] forState: UIControlStateNormal];
    [joinAudioRoomBtn setBackgroundImage:[UIImage imageNamed:@"home_bg_blue"] forState: UIControlStateHighlighted];
    
    joinAudioRoomBtn.layer.cornerRadius = 8;
    joinAudioRoomBtn.layer.masksToBounds = true;
    [contentView addSubview:joinAudioRoomBtn];
}

- (void)initConstraints {
    
    [settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(0).insets(UIEdgeInsetsMake(60, 0, 0, 30));
    }];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.left.right.mas_equalTo(0);
    }];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, defaultMargin * 2, 0, defaultMargin * 2);
    [createAudioRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0).insets(insets);
        make.height.mas_equalTo(110);
    }];
    [joinAudioRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0).insets(insets);
        make.height.equalTo(createAudioRoomBtn);
        make.top.equalTo(createAudioRoomBtn.mas_bottom).offset(30);
    }];
}

- (void)initService {
    
}

- (void)updateVersionAlert:(BOOL)forceUpdate {}


- (void)createRoomAction {
    [self showJoinPage:PanoAnchor];
}

- (void)joinRoomAction {
    [self showJoinPage:PanoAndience];
}

- (void)showJoinPage:(PanoUserMode)userMode {
    PanoJoinViewController *vc = [[PanoJoinViewController alloc] init];
    vc->userMode = userMode;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:true completion:nil];
}

- (void)showSettingPage {
    [self presentViewController:[PanoInterface settingViewController] animated:true completion:nil];
}

+ (NSString *)productShortVersion {
    return [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)productName {
    return [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleName"];
}

@end
