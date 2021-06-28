//
//  SettingTableViewController.m
//  PanoCall
//
//  Created by Sand Pei on 2020/4/3.
//  Copyright © 2020 Pano. All rights reserved.
//

#import "SettingTableViewController.h"
#import "PanoAudioChat-Swift.h"

@interface SettingTableViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField * userName;
//@property (strong, nonatomic) IBOutlet UISwitch * autoMute;
//@property (strong, nonatomic) IBOutlet UISwitch * autoVideo;
//@property (strong, nonatomic) IBOutlet UISegmentedControl * resolution;
//@property (strong, nonatomic) IBOutlet UISwitch * autoSpeaker;
//@property (strong, nonatomic) IBOutlet UISwitch * leaveConfirm;
@property (strong, nonatomic) IBOutlet UISwitch * debugMode;
@property (strong, nonatomic) IBOutlet UILabel * version;

@property (weak, nonatomic) IBOutlet UISwitch *audioAdvanveSwitch;


@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
        PanoClientService.debug = self.debugMode.on;
//        PanoCallClient.sharedInstance.debugMode = self.debugMode.on;
    }
}

- (IBAction)switchAudioPreprocess:(UISwitch *)sender {
    if (PanoClientService.joined) {
        sender.on = !sender.isOn;
        [self.view showToastWithMessage:NSLocalizedString(@"请在加入房间前设置", nil)];
        return;
    }
    PanoClientService.audioAdvanceProcess = sender.isOn;
}

- (IBAction)showEnvAlert:(id)sender {}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//    if ([segue.identifier compare:@"Feedback"] == NSOrderedSame) {
//        UINavigationController * feedbackNavigation = segue.destinationViewController;
//        feedbackNavigation.topViewController.title = NSLocalizedString(@"feedback", nil);
//    }
}

#pragma mark - Editing

- (void)setTextFieldDelegate {
    self.userName.delegate = self;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.userName) {
        PanoClientService.userName = self.userName.text;
//        PanoCallClient.sharedInstance.userName = self.userName.text;
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
        PanoClientService.debug = self.debugMode.on;
        [PanoClientService savePreferences];
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
    
    self.userName.text = PanoClientService.userName;
    
    self.debugMode.on = PanoClientService.debug = self.debugMode.on;;
    
    self.audioAdvanveSwitch.on = PanoClientService.audioAdvanceProcess;
    
    
    self.version.text = [[PanoClientService service] productVersion];
}

@end
