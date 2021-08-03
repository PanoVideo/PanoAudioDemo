//
//  PanoInviteListViewController.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/16.
//

#import <UIKit/UIKit.h>
#import "PanoBaseViewController.h"
#import "PanoClientService.h"

NS_ASSUME_NONNULL_BEGIN

@interface PanoInviteListViewController : PanoBaseViewController

@property (nonatomic, strong) NSArray *onlineUser;
@property (nonatomic, strong) PanoMicInfo *micInfo;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

NS_ASSUME_NONNULL_END
