//
//  UIImage + color.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/7.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func creatImageWithColor(color: UIColor, viewSize: CGSize) -> UIImage {
        
        let rect = CGRect(x: 0.0, y: 0.0, width: viewSize.width, height: viewSize.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
