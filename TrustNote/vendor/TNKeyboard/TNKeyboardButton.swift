//
//  TNKeyboardButton.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/9.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit


enum TNKeyButtonStyle: Int {
    
    case charStyle = 0
    case deleteKey = 1
    case returnStyle = 2
}

class TNKeyboardButton: UIButton {
    
    private let keyShadowColor = UIColor.hexColor(rgbValue: 0x888A8E)
    private let keyColor = UIColor.white
    private let keyCornerRadius = 4.0
    private let otherKeyColor = UIColor.hexColor(rgbValue: 0xAFB2BB)
    
    public var textInput: UITextField!
   
   var keyStyle: TNKeyButtonStyle = .charStyle
    {

        didSet {
            
            switch keyStyle {
            case .charStyle:
                self.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 25.0)
                self.titleLabel?.textAlignment = .center
                self.setTitleColor(UIColor.black, for: .normal)
                self.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 4, 0)
            case .deleteKey:
                self.setImage(UIImage(named: "keyboard_delete"), for: .normal)
            case .returnStyle:
                self.setImage(UIImage(named: "keyboard_resign"), for: .normal)
            }
        }
   }

   override init(frame: CGRect) {
        super.init(frame: frame)
    
        self.titleLabel?.sizeToFit()
        self.contentHorizontalAlignment = .center
        self.addTarget(self, action: #selector(self.handleTouchUpInside), for: .touchUpInside)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        let shadowOffset = CGSize(width: 0.1, height: 1.1)
        let shadowBlurRadius = 0
        let roundedRectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - 1), cornerRadius: CGFloat(keyCornerRadius))
        context.saveGState()
        context.setShadow(offset: shadowOffset, blur: CGFloat(shadowBlurRadius), color: keyShadowColor.cgColor)
        if self.keyStyle == .charStyle {
            keyColor.setFill()
        } else {
            otherKeyColor.setFill()
        }
        roundedRectanglePath.fill()
        context.restoreGState()
    }
    
}

/// Mark: handle events
extension TNKeyboardButton {
    
    @objc fileprivate func handleTouchUpInside() {
        
        let superView: TNKeyboardView = self.superview as! TNKeyboardView
        self.textInput = superView.textInput
        
        switch keyStyle {
           
        case .charStyle:
            self.insertText(text: self.currentTitle!)
        case .deleteKey:
            self.insertText(text: "")
        case .returnStyle:
            textInput.resignFirstResponder()
        }
    }
    
    fileprivate func insertText(text: String) {
        
        func textInputSelectedRange() -> NSRange {
            
            let beginning = textInput.beginningOfDocument
            let selectedRange = textInput.selectedTextRange
            let selectionStart = selectedRange?.start
            let selectionEnd = selectedRange?.end
            
            let location = textInput.offset(from: beginning, to: selectionStart!)
            
            let length = textInput.offset(from: selectionStart!, to: selectionEnd!)
            
            return NSRange(location: location, length: length)
        }
        
        var shouldInsertText: Bool = true
        let textField: UITextField = textInput
        let range = textInputSelectedRange()
        
        guard  text.count > 0 else {
            
            let length: Int! = textField.text?.count
            guard length > 0 && range.location != 0 else {
                return
            }
           
            let fromPosition = textField.position(from: textInput.beginningOfDocument, offset: range.location - 1)
            let toPosition = textField.selectedTextRange?.start
            let textRange = textField.textRange(from: fromPosition!, to: toPosition!)
            textField.replace(textRange!, withText: text)
//            let offsetIndex: String.Index = inputStr!.index(inputStr!.startIndex, offsetBy: range.location - 1)
//            inputStr!.remove(at: offsetIndex)
//            textField.text = inputStr
//            textField.insertText(text)
            return
        }
        shouldInsertText = (textField.delegate?.textField!(textField, shouldChangeCharactersIn: range, replacementString: text))!

        guard shouldInsertText else {
            return
        }
        
        textField.insertText(text)
        
    }
    
}
