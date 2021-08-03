//
//  UIImage+Extension.h
//  PanoVideoCall
//
//  Created by pano on 2021/5/8.
//  Copyright © 2021 Pano. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Extension)

+ (UIImage *)pano_imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)pano_imageWithColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
