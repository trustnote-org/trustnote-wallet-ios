//
//  UIColor+Extention.swift
//  TrustNote
//
//  Created by 曾海龙 on 2018/3/23.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func hexColor(rgbValue: UInt) -> UIColor {

        return UIColor.hexColor(rgbValue: rgbValue, alpha: 1.0)
    }
    
    static func hexColor(rgbValue: UInt, alpha: CGFloat) -> UIColor {
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha)
    }
}

