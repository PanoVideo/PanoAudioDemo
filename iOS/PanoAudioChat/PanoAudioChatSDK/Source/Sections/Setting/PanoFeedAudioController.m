//
//  PanoFeedAudioController.m
//  PanoAudioChat
//
//  Created by pano on 2021/7/22.
//

#import "PanoFeedAudioController.h"
#import "PanoGrowingTextView.h"
#import "PanoClientService+App.h"

@interface PanoFeedAudioController ()

@property (weak, nonatomic) IBOutlet PanoGrowingTextView *textview;

@end

@implementation PanoFeedAudioController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"音频故障日志上传", nil);
    _textview.layer.cornerRadius = 5;
    _textview.layer.masksToBounds = true;
    _textview.layer.borderWidth = 1;
    _textview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _textview.placeholder = NSLocalizedString(@"问题描述", nil);
}


- (void)initService {
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)]];
}

- (IBAction)sendAction:(id)sender {
    [PanoClientService.service notifyOthersUploadLogs:kPanoFeedbackAudio message:_textview.text];
    [super dismiss];
}

- (void)hideKeyboard {
    [_textview resignFirstResponder];
}

@end
