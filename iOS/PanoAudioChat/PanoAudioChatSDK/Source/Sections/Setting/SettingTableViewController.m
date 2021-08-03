//
//  SettingTableViewController.m
//  PanoCall
//
//  Created by Sand Pei on 2020/4/3.
//  Copyright © 2020 Pano. All rights reserved.
//

#import "SettingTableViewController.h"
#import "PanoClientService.h"
#import "MBProgressHUD+Extension.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "PanoClientService+App.h"

@interface SettingTableViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField * userName;
@property (strong, nonatomic) IBOutlet UISwitch * debugMode;
@property (strong, nonatomic) IBOutlet UILabel * version;

@property (weak, nonatomic) IBOutlet UISwitch *audioAdvanveSwitch;


@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLocalizable];
    [self setTextFieldDelegate];
    [self initialize];
}

- (IBAction)clickBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)switchDebugMode:(id)sender {
    if (self.debugMode.on) {
        [self presentDebugModeAlert];
    } else {
        PanoClientService.service.audioDebug = self.debugMode.on;
    }
}

- (IBAction)switchAudioPreprocess:(UISwitch *)sender {
    if (PanoClientService.service.joined) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.on = !sender.isOn;
        });
        [MBProgressHUD showMessage:NSLocalizedString(@"请在加入房间前设置", nil) addedToView:self.view duration:3];
        return;
    }
    PanoClientService.service.audioAdvanceProcess = sender.isOn;
    NSLog(@"->%d",PanoClientService.service.audioAdvanceProcess);
}

- (IBAction)showEnvAlert:(id)sender {}

#pragma mark - Navigation


#pragma mark - Editing

- (void)setTextFieldDelegate {
    self.userName.delegate = self;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.userName) {
        PanoClientService.service.userName = self.userName.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Alert

- (void)presentDebugModeAlert {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@""
                                                                    message:NSLocalizedString(@"debugAlert", nil)
                                                             preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil)
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
        PanoClientService.service.audioDebug = self.debugMode.on;
        [PanoClientService.service savePreferences];
//        PanoCallClient.sharedInstance.debugMode = self.debugMode.on;
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
        self.debugMode.on = NO;
    }];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Private

- (void)setLocalizable {
    self.title = NSLocalizedString(@"设置", nil);
}

- (void)initialize {
    
    self.userName.text = PanoClientService.service.userName;
    
    self.debugMode.on = PanoClientService.service.audioDebug;
    
    self.audioAdvanveSwitch.on = PanoClientService.service.audioAdvanceProcess;
    
    self.version.text = [PanoClientService productVersion];
}

@end
