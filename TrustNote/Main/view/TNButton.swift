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

