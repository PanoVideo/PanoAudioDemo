//
//  PanoItemDelegate.h
//  PanoVideoCall
//
//  Created by pano on 2020/10/20.
//  Copyright © 2020 Pano. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PanoClickBlock_t)(void);

@protocol PanoItemDelegate <NSObject>

- (PanoClickBlock_t)clickBlock;

- (UIImage *)image;

- (NSString *)title;

@end

NS_ASSUME_NONNULL_END
