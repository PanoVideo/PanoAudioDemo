//
//  PanoBaseViewController.m
//  PanoVideoCall
//
//  Created by pano on 2020/11/19.
//  Copyright © 2020 Pano. All rights reserved.
//

#import "PanoBaseViewController.h"
#import "UIImage+Extension.h"

@interface PanoBaseViewController ()

@end

@implementation PanoBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"app_back"] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    [self initViews];
    [self initConstraints];
    [self initService];
}

- (void)initViews {
    
}

- (void)initConstraints {
    
}

- (void)initService {
    
}

- (void)dismiss {
    [self dismissViewControllerAnimated:true completion:^{
    }];
}

- (void)dealloc {
    NSLog(@"%@ dealloc", self);
}

@end
