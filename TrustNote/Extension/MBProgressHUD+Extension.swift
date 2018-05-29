//
//  MBProgressHUD+Extension.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/28.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import MBProgressHUD

class MBProgress_TNExtension {
    
}

extension MBProgress_TNExtension {
    
    class func showHUDAddedToView(view : UIView, title : String, animated : Bool) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: view, animated: animated)
        hud.label.font = UIFont.systemFont(ofSize: 14.0)
        hud.label.text = title
        hud.label.textColor = UIColor.white
        hud.bezelView.style = .blur
        hud.bezelView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        hud.activityIndicatorColor = UIColor.white
        return hud
    }
    
    class func showHUDAddToViewWithoutAnimate(view : UIView, title : String) -> MBProgressHUD {
        
        let hud = MBProgressHUD.showAdded(to: view, animated: false)
        hud.label.font = UIFont.systemFont(ofSize: 14.0)
        hud.label.text = title
        hud.label.textColor = UIColor.white
        hud.bezelView.style = .blur
        hud.bezelView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        return hud
    }
   
    class func showAlertMessage(alertMessage: String, customView: UIView) {
        let view = UIApplication.shared.delegate?.window as? UIView
        let hud = MBProgressHUD.showAdded(to: view!, animated: true)
        hud.mode = .customView
        hud.label.text = alertMessage
        hud.customView = customView
        hud.bezelView.style = .solidColor
        hud.bezelView.backgroundColor = kTitleTextColor
        hud.label.textColor = UIColor.hexColor(rgbValue: 0xF4F4F4)
        hud.label.font = UIFont.systemFont(ofSize: 12)
        hud.label.numberOfLines = 0
        hud.bezelView.alpha = 0.8
        hud.hide(animated: true, afterDelay: 1.5)
    }

}
