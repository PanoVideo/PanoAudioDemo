//
//  UIViewExtension.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/3.
//

import Foundation
import Toast_Swift

extension UIView {
    func pano_autoLayout() {
        UIView.animate(withDuration: 0.3) {
            self.setNeedsLayout()
            self.updateConstraintsIfNeeded()
            self.layoutIfNeeded()
        };
    }
}


extension UIView {
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius ))
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension UIView {
    @objc func showToast(message: String) {
        self.makeToast(message, duration: 3, position: .center, title: nil, image: nil, style: ToastStyle(), completion: nil)
    }
}
