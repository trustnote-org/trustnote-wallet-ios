//
//  TNButton.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/7.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol CustomButtonProtocol {
    var isValid: Bool { get set }
}

class TNButton: UIButton{
   
    
    override var isHighlighted: Bool {
        set{
            
        }
        get {
            return false
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = kCornerRadius
        self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIButton {
    var rx_validState: AnyObserver<Bool> {
        return Binder(self) { button, valid in
            button.isEnabled = valid
            button.alpha = valid ? 1.0 : 0.3
        }.asObserver()
    }
    
    var rx_HiddenState: AnyObserver<Bool> {
        return Binder(self) { button, hidden in
            button.isHidden = !hidden
        }.asObserver()
    }
}

extension UIButton {
    func relayoutButton() {
        let spacing: CGFloat = 5
        let imageSize = self.imageView!.frame.size
        var titleSize = self.titleLabel!.frame.size
        let textSize  = self.titleLabel!.text!.size(withAttributes: [NSAttributedStringKey.font : self.titleLabel!.font])
        let frameSize = CGSize(width: textSize.width, height: textSize.height)
        if titleSize.width + 0.5 < frameSize.width {
            titleSize.width = frameSize.width
        }
        let totalHeight = imageSize.height + titleSize.height + spacing
        self.imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight - imageSize.height), 0.0, 0.0, -titleSize.width);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width, -(totalHeight - titleSize.height), 0);
    }
}

