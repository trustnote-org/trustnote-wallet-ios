//
//  UIView+Animation.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/13.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

protocol KeyFrameAnimatedProtocol {
    func shakeAnimation(scope: CGFloat)
}
extension UIView: KeyFrameAnimatedProtocol {
    
    func shakeAnimation(scope: CGFloat) {
        let KeyframeAnimated = CAKeyframeAnimation(keyPath: "transform.translation.x")
        KeyframeAnimated.values = [-scope, 0, scope, 0, -scope, 0, scope, 0]
        KeyframeAnimated.duration = 0.2
        KeyframeAnimated.repeatCount = 2
        self.layer.add(KeyframeAnimated, forKey: "shake")
    }
}
