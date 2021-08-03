//
//  PanoAvatorUtil.h
//  PanoVideoCall
//
//  Created by pano on 2020/12/1.
//  Copyright © 2020 Pano. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PanoAvatorUtil : NSObject

+ (UIImage *)avatorView:(NSString *) name width:(CGFloat)width;

+ (UIColor *)getRandomColor:(NSString *)name;

+ (NSString *)getAvatarName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
