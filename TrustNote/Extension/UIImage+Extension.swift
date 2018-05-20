//
//  UIImage+Extension.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/19.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import CoreImage

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

extension UIImage {
    
    static func createHDQRImage(input: String, imgSize: CGSize) -> UIImage {
        
        let fileter = CIFilter(name: "CIQRCodeGenerator")
        let inputData = input.data(using: String.Encoding.utf8)
        fileter?.setValue(inputData, forKeyPath: "inputMessage")
        fileter?.setValue("H", forKey: "inputCorrectionLevel")
        let outPutImage = fileter?.outputImage
        
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(outPutImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
        colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
        // Create Transform
        // Create Transform
        let scale = imgSize.width / outPutImage!.extent.width
        
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        
        let hdImage = fileter!.outputImage!.transformed(by: transform)
        
        return UIImage(ciImage: hdImage)
    }
}
