//
//  PanoJoinViewController.m
//  PanoAudioChat
//
//  Created by pano on 2021/7/20.
//

#import "PanoJoinViewController.h"
#import "PanoTextField.h"
#import "PanoClientService.h"
#import "PanoDefine.h"
#import <Masonry/Masonry.h>
#import "PanoInterface.h"
#import "MBProgressHUD+Extension.h"

@interface PanoJoinViewController () <UITextFieldDelegate>

@end

@implementation PanoJoinViewController {
    
    PanoTextField *joinRoomTF;
    
    PanoTextField *userNameTF;
    
    UIButton *joinBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"app_back"] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = userMode == PanoAnchor ?
        NSLocalizedString(@"Create a chat room", nil) :
        NSLocalizedString(@"Join the chat room", nil);
    
    joinRoomTF = [[PanoTextField alloc] init];
    joinRoomTF->textfiled.keyboardType = UIKeyboardTypeASCIICapable;
    joinRoomTF->leftLabel.text = NSLocalizedString(@"房间号", nil);
    joinRoomTF->textfiled.placeholder = NSLocalizedString(@"输入房间ID/房间号", nil);
    joinRoomTF->textfiled.delegate = self;
    [self.view addSubview:joinRoomTF];
    
    if (userMode != PanoAnchor) {
        joinRoomTF->textfiled.text = PanoClientService.service.roomId;
    }
    
    userNameTF = [[PanoTextField alloc] init];
    userNameTF->leftLabel.text = NSLocalizedString(@"用户名", nil);
    userNameTF->textfiled.placeholder = NSLocalizedString(@"输入昵称", nil);
    [self.view addSubview:userNameTF];
    
    userNameTF->textfiled.text = PanoClientService.service.userName;
    
    
    NSString *joinTitle = userMode == PanoAnchor ?
        NSLocalizedString(@"确认创建", nil) :
    NSLocalizedString(@"确认加入", nil);
    
    joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [joinBtn addTarget:self action:@selector(join) forControlEvents:UIControlEventTouchUpInside];
    [joinBtn setTitle:joinTitle forState:UIControlStateNormal];
    joinBtn.titleLabel.font = fontMedium();
    [joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [joinBtn setBackgroundImage:[UIImage imageNamed:@"home_bg_blue"] forState: UIControlStateNormal];
    [joinBtn setBackgroundImage:[UIImage imageNamed:@"home_bg_blue"] forState: UIControlStateHighlighted];
    joinBtn.layer.masksToBounds = true;
    joinBtn.layer.cornerRadius = 20;
    [self.view addSubview:joinBtn];
}

- (void)initConstraints {
    
    [joinRoomTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0).insets(UIEdgeInsetsMake(120, defaultMargin, 0, defaultMargin));
    }];
    
    [userNameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0).insets(UIEdgeInsetsMake(0, defaultMargin, 0, defaultMargin));
        make.top.equalTo(joinRoomTF.mas_bottom).offset(30);
    }];
    
    [joinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0).insets(UIEdgeInsetsMake(0, defaultMargin, 0, defaultMargin));
        make.top.equalTo(self->userNameTF.mas_bottom).offset(30);
        make.height.mas_equalTo(44);
    }];
}

- (void)join {
    NSString *userName = userNameTF->textfiled.text;
    NSString * roomId = joinRoomTF->textfiled.text;
    
    if (!(userName.length > 0 && roomId.length > 0)) {
        [MBProgressHUD showMessage:NSLocalizedString(@"请输入房间号和用户名", nil) addedToView:self.view duration:3];
        return;
    }
    UInt64 userId = PanoClientService.service.userId;
    if ( userId == 0) {
        userId = [self randomUserId];
    }
    PanoClientConfig *config = [[PanoClientConfig alloc] init];
    config.userName = userName;
    config.roomId = roomId;
    config.userId = userId;
    config.userMode = userMode;
    UIViewController *vc = [PanoInterface instantiateViewControllerWithConfig:config];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navi animated:true completion:nil];
}

- (UInt64)randomUserId {
    const static UInt64 baseRandom = 1000000;
    const static UInt64 baseId = 11 * baseRandom;
    return baseId + arc4random() % baseRandom;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/// MARK
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == joinRoomTF->textfiled) {
        if ((textField.text.length >= 20) && ![string isEqualToString:@""]) {
            return NO;
        }
        if ([self isInputCharAvailable:string]) {
            return true;
        }
    }
    return true;
}

- (BOOL)isInputCharAvailable:(NSString *)str {
    NSString *pattern = @"^[0-9a-zA-Z]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}

- (void)dismiss {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
