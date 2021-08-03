//
//  PanoBaseService.m
//  PanoVideoCall
//
//  Created by pano on 2020/9/28.
//  Copyright © 2020 Pano. All rights reserved.
//

#import "PanoBaseService.h"
#import "PanoMulticastDelegate.h"

@interface PanoBaseService ()
@property (nonatomic, strong) PanoMulticastDelegate *delegates;
@end

@implementation PanoBaseService

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegates = [[PanoMulticastDelegate alloc] init];
        [self initService];
    }
    return self;
}

- (void)initService {
    
}

- (void)addDelegate:(id)delegate {
    [_delegates addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id)delegate {
    [_delegates removeDelegate:delegate];
}

- (void)removeAllDelegates {
    [_delegates removeAllDelegates];
}

- (void)invokeWithAction:(SEL)selector completion:(PanoCallBackBlock)completion {
    PanoMulticastDelegateEnumerator *delegateEnum = _delegates.delegateEnumerator;
    id del;
    dispatch_queue_t dq;
    while ([delegateEnum getNextDelegate:&del delegateQueue:&dq forSelector:selector]) {
        dispatch_async(dq, ^{
            if (completion) {
                completion(del);
            }
        });
    }
}

- (void)dealloc {
    NSLog(@"self->%@",self);
    [self removeAllDelegates];
}

@end
