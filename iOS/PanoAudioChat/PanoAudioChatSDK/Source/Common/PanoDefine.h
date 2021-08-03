//
//  PanoDefine.h
//  PanoVideoCall
//
//  Created by pano on 2020/9/28.
//  Copyright © 2020 Pano. All rights reserved.
//

#ifndef PanoDefine_h
#define PanoDefine_h
#import "UIColor+Extension.h"
#import "UIImage+Extension.h"

typedef NS_ENUM(NSInteger, PanoFontSize) {
    PanoFontSize_Min = 10,
    PanoFontSize_Little = 12,
    PanoFontSize_Medium = 16,
    PanoFontSize_Larger = 18,
    PanoFontSize_Max = 22
};
static CGFloat defaultMargin = 15.0;


static inline UIFont* fontMax() {
    return [UIFont systemFontOfSize:PanoFontSize_Max];
}

static inline UIFont* fontLarger() {
    return [UIFont systemFontOfSize:PanoFontSize_Larger];
}

static inline UIFont* fontMedium() {
    return [UIFont systemFontOfSize:PanoFontSize_Medium];
}

static inline UIFont* fontLittle() {
    return [UIFont systemFontOfSize:PanoFontSize_Little];
}

static inline UIFont* fontMin() {
    return [UIFont systemFontOfSize:PanoFontSize_Min];
}

static inline UIColor* defaultTextColor() {
    return [UIColor pano_colorWithHexString:@"#333333"];
}

static inline UIColor* defaultBorderColor() {
    return [UIColor pano_colorWithHexString:@"#EEEEEE"];
}

static CGFloat DefaultViewHeight = 40.0;


static CGFloat ButtonHeight = 44.0;


static inline BOOL isIphoneX() {
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeInsets = [UIApplication sharedApplication].keyWindow.safeAreaInsets;
        return safeInsets.bottom > 0 && safeInsets.top > 0;
    } else {
        return false;
    }
}

static inline CGFloat panoStatusBarHeight() {
    return isIphoneX() ? 44 : 20;
}


static inline BOOL isiPad() {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

static inline UIEdgeInsets pano_safeAreaInset(UIView *view) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if ([view respondsToSelector:@selector(safeAreaInsets)]) {
        if (@available(iOS 11.0, *)) {
            return [view safeAreaInsets];
        }
    }
#endif
    return UIEdgeInsetsZero;
}

static inline CGFloat statusBarHeight() {
    return isIphoneX() ? 44 : 20;
}

static inline BOOL PanoIsPhone() {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}
static CGFloat LargeFixSpace = 15.0;

static CGFloat DefaultFixSpace = 7.5;

static CGFloat LittleFixSpace = 5;

#define PanoAppWidth UIScreen.mainScreen.bounds.size.width

#define PanoAppHeight UIScreen.mainScreen.bounds.size.height

static inline void pano_main_sync_safe(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}


#endif /* PanoDefine_h */
