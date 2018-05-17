//
//  TNPopControl.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/17.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNPopControl: UIControl {
    init(frame: CGRect, imageName: String, title: String, hiddenLine: Bool) {
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor.white
        
        let w = frame.size.width
        let h = frame.size.height
        
        let label_x: CGFloat = 55.0
        let label_h = h * 0.5
        let label_y = (h - label_h) * 0.5
        let label_w = w - label_x
        
        var label_rect = CGRect()
        label_rect.origin.x = label_x
        label_rect.origin.y = label_y
        label_rect.size.width = label_w
        label_rect.size.height = label_h
        
        let titleLabel = UILabel(frame: label_rect)
        titleLabel.text = title
        titleLabel.textColor = kThemeTextColor
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        self.addSubview(titleLabel)
        
        let imageView_h = UIImage(named: imageName)?.size.height
        let imageView_w = UIImage(named: imageName)?.size.width
        let imageView_x: CGFloat = (label_x - imageView_w!) * 0.5
        let imageView_y = (h - imageView_h!) * 0.5
        var imageView_rect = CGRect()
        imageView_rect.origin.x = imageView_x
        imageView_rect.origin.y = imageView_y
        imageView_rect.size.width = imageView_w!
        imageView_rect.size.height = imageView_h!
        
        let imageView = UIImageView(frame: imageView_rect)
        imageView.image = UIImage(named: imageName)
        self.addSubview(imageView)
        
        let line_x: CGFloat = 12.0
        let line_y = h - 0.5
        let line_w = w - 2 * line_x
        let line_h: CGFloat = 1.0
        var line_rect = CGRect()
        line_rect.origin.x = line_x
        line_rect.origin.y = line_y
        line_rect.size.width = line_w
        line_rect.size.height = line_h
        let line = UIView(frame: line_rect)
        line.backgroundColor = UIColor.hexColor(rgbValue: 0xE9EFF7)
        line.isHidden = hiddenLine
        self.addSubview(line)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
