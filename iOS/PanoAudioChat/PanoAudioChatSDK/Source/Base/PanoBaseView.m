//
//  PanoBaseView.m
//  PanoVideoCall
//
//  Created by pano on 2020/9/28.
//  Copyright © 2020 Pano. All rights reserved.
//

#import "PanoBaseView.h"

@implementation PanoBaseView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    
}

- (void)initConstraints {
    
}

@end
