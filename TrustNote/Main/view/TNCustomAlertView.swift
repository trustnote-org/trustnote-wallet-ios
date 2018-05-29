//
//  TNCustomAlertView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/19.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import pop

typealias ClickedDismissButtonBlock = () -> Void

enum TNAlertAnimatedStyle {
    case none
    case transform
    case pop
}

class TNCustomAlertView: UIView {
    
    var alertView: UIView?
    
    var alertBounds: CGRect!
    
    init(alert: UIView, alertFrame: CGRect, AnimatedType: TNAlertAnimatedStyle) {
        super.init(frame: UIScreen.main.bounds)
        
        self.backgroundColor = UIColor.hexColor(rgbValue: 0xD3DFF1, alpha: 0.8)
        alertView = alert
        alert.frame = alertFrame
        alertBounds = CGRect(x: 0, y: 0, width: alertFrame.size.width, height: alertFrame.size.height)
        self.addSubview(alertView!)
        let keyWindow = UIApplication.shared.keyWindow
        keyWindow?.addSubview(self)
        switch AnimatedType {
        case .none:
            break
        case .transform:
            showTransformAnimation()
        case .pop:
            showPopAnimation()
        }
    }
    
    private func showTransformAnimation() {
        alertView!.transform = CGAffineTransform(translationX: 0, y: -kScreenH * 0.5)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.alertView!.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    private func showPopAnimation() {
        let scale = POPSpringAnimation(propertyNamed: kPOPViewBounds)
        scale?.toValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: alertBounds.size.width * 0.98, height: alertBounds.size.height * 0.98))
        scale?.springBounciness = 20
        scale?.springSpeed = 1
        alertView?.pop_add(scale!, forKey:"scale")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
