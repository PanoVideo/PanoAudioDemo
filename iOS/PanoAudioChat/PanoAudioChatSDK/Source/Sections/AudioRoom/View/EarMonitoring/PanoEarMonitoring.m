//
//  PanoChatView.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoEarMonitoring.h"
#import "PanoClientService.h"
#import "MBProgressHUD+Extension.h"

@implementation PanoEarMonitoring {
    UISwitch *mySwitch;
    UISlider *slider;
    UILabel *titleLabel;
    UIButton *cancelBtn;
    UITableViewCell *switchCell;
    UITableViewCell *sliderCell;
    UIView *contentView;
    UIView *coverView;
}

- (void)initViews {
    coverView = [UIView new];
    coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
    [self addSubview:coverView];
    
    contentView = [UIView new];
    contentView.layer.cornerRadius = 10;
    contentView.layer.masksToBounds = true;
    contentView.backgroundColor = [UIColor pano_colorWithHexString:@"#EEEFF2"];
    [self addSubview:contentView];
    
    titleLabel = [UILabel new];
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.font = fontLarger();
    titleLabel.textColor = defaultTextColor();
    titleLabel.text = NSLocalizedString(@"耳返设置", nil);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:titleLabel];
    
    
    mySwitch = [[UISwitch alloc] init];
    mySwitch.on = false;
    [mySwitch addTarget:self action:@selector(earMonitoring:) forControlEvents:UIControlEventValueChanged];
   
    switchCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"c1"];
    switchCell.textLabel.text = NSLocalizedString(@"耳返设置", nil);
    switchCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switchCell.accessoryView = mySwitch;
    switchCell.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:switchCell];
    
    slider = [[UISlider alloc] init];
    slider.minimumValue = 1;
    slider.maximumValue = 255;
    [slider addTarget:self action:@selector(volumeChanged:) forControlEvents:UIControlEventValueChanged];
    sliderCell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"c2"];
    sliderCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    sliderCell.textLabel.text = NSLocalizedString(@"耳返设置", nil);
    sliderCell.accessoryView = slider;
    CGRect oldFrame = sliderCell.accessoryView.frame;
    CGFloat x = sliderCell.textLabel.frame.origin.x + sliderCell.textLabel.frame.size.width;
    sliderCell.accessoryView.frame = CGRectMake(x + 30, oldFrame.origin.y, 200, oldFrame.size.height);
    slider.value = 100;
    sliderCell.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:sliderCell];
    
    cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [cancelBtn setTitleColor:defaultTextColor() forState:UIControlStateNormal];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:cancelBtn];
    
}

- (void)initConstraints {
    [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(58);
    }];
    
    [switchCell mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.equalTo(titleLabel.mas_bottom);
        make.height.mas_equalTo(58);
    }];
    
    [sliderCell mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.equalTo(switchCell.mas_bottom);
        make.height.mas_equalTo(58);
    }];
    
    [cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(58);
    }];
    
    [contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(58 * 4 + 20);
    }];
    [coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(contentView.mas_top);
    }];
}

- (void)earMonitoring:(UISwitch *)mySwitch {
    if (mySwitch.isOn && ![PanoAudioService hasHeadphonesDevice]) {
        [MBProgressHUD showMessage:NSLocalizedString(@"请插上耳机体验", nil) addedToView:self duration:3];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            mySwitch.on = false;
        });
        return;
    }
    [PanoClientService.service.audioService enableAudioEarMonitoring: mySwitch.isOn];
}

- (void)volumeChanged:(UISlider *)slider  {
    printf("setAudioDeviceVolume: %f", slider.value);
    [PanoClientService.service.audioService setAudioDeviceVolume:(UInt32)slider.value];
}

- (void)dismiss {
    [self removeFromSuperview];
}

- (void)showInView:(UIView *)parentView {
    if (![parentView.subviews containsObject:self]) {
        [parentView addSubview:self];
    }
    self.alpha = 0.1;
    CGRect frame = parentView.frame;
    frame.origin.y = frame.size.height;
    self.frame = frame;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }];
}


@end
