//
//  PanoMicButton.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/10/29.
//

import UIKit

class PanoMicButton: UIButton {
    
    var isAnimating = false
    var animationLayer : CALayer?
    
    func startAnimating() {
        if isAnimating {
            return
        }
        let layer = CALayer()
        let pulsingCount = 5, animationDurtaion = 5.0
        for index in 0..<pulsingCount {
            let pulsingLayer = CALayer()
            pulsingLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            pulsingLayer.borderColor = UIColor("#35A4FE").cgColor
            pulsingLayer.borderWidth = 1.5
            pulsingLayer.cornerRadius = self.frame.size.width / 2.0
            
            let animationGroup = CAAnimationGroup()
            animationGroup.fillMode = .backwards
            animationGroup.beginTime = CACurrentMediaTime() + Double(index) * Double(animationDurtaion) / Double(pulsingCount)
            animationGroup.duration = animationDurtaion
            animationGroup.repeatCount = Float(Int.max)
            animationGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
            animationGroup.isRemovedOnCompletion = false
            
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = 1.0
            scaleAnimation.toValue = 1.6
            
            let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnimation.values = [1, 0.5, 0]
            opacityAnimation.keyTimes = [0, 0.5, 1]
            
            animationGroup.animations = [scaleAnimation, opacityAnimation]
            pulsingLayer.add(animationGroup, forKey: "plulsing")
            
            layer.addSublayer(pulsingLayer)
        }
        animationLayer = layer
        self.layer.addSublayer(layer)
        isAnimating = true
    }
    
    func stopAnimating() {
        if !isAnimating {
            return
        }
        if let layers = animationLayer?.sublayers {
            for layer in layers {
                layer.removeAllAnimations()
            }
            for layer in layers {
                layer.removeFromSuperlayer()
            }
        }
        animationLayer?.removeFromSuperlayer()
        animationLayer = nil
        isAnimating = false
    }
}
