//
//  UIWindow+Extension.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/27.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

enum TNWindowRoot: Int {
    case clause      = 1     // Agree Protocol
    case deviceName  = 2     // modify device name
    case newWallet   = 3     // New wallet
    case main        = 4     // main page
}

extension UIWindow {
    
    static func setWindowRootController(_ keyWindow: UIWindow?,  rootVC: TNWindowRoot) {
        
        var rootController: UIViewController {
            
            switch rootVC {
            case .clause:
                return TNProtocolViewController()
            case .deviceName:
                return TNModifyDeviceNameController()
            case .newWallet:
                return TNBaseNavigationController(rootViewController: TNCreateAndRestoreWalletController())
            case .main:
                if TNGlobalHelper.shared.isVerifyPasswdForMain {
                    let vc = TNVerifyPasswordController()
                    vc.isDismissAnimated = false
                    return  vc
                }
                return TNTabBarController()
            }
        }
        keyWindow?.rootViewController = rootController
        
    }
    
}
