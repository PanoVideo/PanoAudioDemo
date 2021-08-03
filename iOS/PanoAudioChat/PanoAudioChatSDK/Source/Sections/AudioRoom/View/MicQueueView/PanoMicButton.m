//
//  PanoMicButton.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoMicButton.h"
#import "UIColor+Extension.h"

@implementation PanoMicButton {
    BOOL isAnimating;
    CALayer *animationLayer;
}


- (void)startAnimating {
    if (isAnimating) {
        return;
    }
    CALayer *layer = [CALayer layer];
    NSInteger pulsingCount = 5;
    NSTimeInterval animationDurtaion = 5.0;
    
    for (NSInteger i=0; i<pulsingCount; i++) {
        CALayer * pulsingLayer = [CALayer layer];
        pulsingLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        pulsingLayer.borderColor = [UIColor pano_colorWithHexString:@"#35A4FE"].CGColor;
        pulsingLayer.borderWidth = 1.5;
        pulsingLayer.cornerRadius = self.frame.size.width / 2.0;
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.fillMode = kCAFillModeBackwards;
        animationGroup.beginTime = CACurrentMediaTime() + i * animationDurtaion / (CGFloat)pulsingCount;
        animationGroup.duration = animationDurtaion;
        animationGroup.repeatCount = NSUIntegerMax;
        
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionDefault];
        animationGroup.removedOnCompletion = false;
        
        CABasicAnimation *scaleAnimation =
        [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = @1.0;
        scaleAnimation.toValue = @1.6;
        
        CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.values = @[@1, @0.5, @0];
        opacityAnimation.keyTimes = @[@0, @0.5, @1];
        
        animationGroup.animations = @[scaleAnimation, opacityAnimation];
        [pulsingLayer addAnimation:animationGroup forKey:@"plulsing"];
        [layer addSublayer:pulsingLayer];
    }
    animationLayer = layer;
    [self.layer addSublayer:layer];
    isAnimating = true;
}

- (void)stopAnimating {
    if (!isAnimating) {
        return;
    }
    NSArray *layers = [animationLayer sublayers];
    for (CALayer *layer in layers) {
        [layer removeAllAnimations];
    }
    [layers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [animationLayer removeFromSuperlayer];
    animationLayer = nil;
    isAnimating = false;
}

@end
