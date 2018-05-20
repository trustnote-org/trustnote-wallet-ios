//
//  TNCustomAlertView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/19.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

typealias ClickedDismissButtonBlock = () -> Void

class TNCustomAlertView: UIView {
    
    var alertView: UIView?
    
    init(alert: UIView, alertFrame: CGRect, isShowAnimated: Bool) {
        super.init(frame: UIScreen.main.bounds)
        
        self.backgroundColor = UIColor.hexColor(rgbValue: 0xD3DFF1, alpha: 0.8)
        alertView = alert
        alert.frame = alertFrame
        self.addSubview(alertView!)
        let keyWindow = UIApplication.shared.keyWindow
        keyWindow?.addSubview(self)
        guard isShowAnimated else {
            return
        }
        showAnimated()
    }
    
    private func  showAnimated() {
        alertView!.transform = CGAffineTransform(translationX: 0, y: -kScreenH * 0.5)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.alertView!.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
