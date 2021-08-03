//
//  PanoBaseViewController.h
//  PanoVideoCall
//
//  Created by pano on 2020/11/19.
//  Copyright © 2020 Pano. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PanoBaseViewController : UIViewController

- (void)initViews;

- (void)initConstraints;

- (void)initService;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
