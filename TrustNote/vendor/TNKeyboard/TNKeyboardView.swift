//
//  TNKeyboardView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/9.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNKeyboardView: UIView {

    private let rows = [["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
                ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
                ["z", "x", "c", "v", "b", "n", "m"]]
    
    private var keyButtons: Array<TNKeyboardButton> = []
    
    private let topPadding: CGFloat = 14
    private let keyHeight: CGFloat = 40
    private let keySpacing: CGFloat = 3
    private let rowSpacing: CGFloat = 12
    private let columnSpacing: CGFloat = 6
    
    fileprivate var deleteKey: UIButton?
    
    public var textInput: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.hexColor(rgbValue: 0xE0E0E0)
        self.frame.size.height = topPadding * 2 + keyHeight * CGFloat(rows.count) + rowSpacing * (CGFloat(rows.count) - 1)
        self.frame.size.width = kScreenW
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TNKeyboardView {
    
    fileprivate func setupSubviews() {
        
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 0.5))
        lineView.backgroundColor = UIColor.hexColor(rgbValue: 0xaaaaaa)
        addSubview(lineView)
        
        let topRowKeyCount = rows.first?.count
        var y: CGFloat = topPadding
        let keyWidth = (self.frame.size.width - 2 * keySpacing - columnSpacing * CGFloat(topRowKeyCount! - 1)) / CGFloat(topRowKeyCount!)
        
        for row in rows {
            
            var x = row.count == topRowKeyCount ? keySpacing : ceil((self.frame.size.width - (CGFloat(row.count) - 1) * (columnSpacing + keyWidth) - keyWidth) / 2.0)
            
            for label in row {
                
                let keyButton = TNKeyboardButton(frame: CGRect(x: x, y: y, width: keyWidth, height: keyHeight))
                keyButton.keyStyle = .charStyle
                keyButton.setTitle(label, for: .normal)
                addSubview(keyButton)
                keyButtons.append(keyButton)
                x += keyWidth + columnSpacing
            }
            
            if row.count == rows.last?.count {
                let deleteKey = TNKeyboardButton(frame: CGRect(x: self.frame.size.width - 2 * keySpacing - keyHeight, y: y, width: keyHeight, height: keyHeight))
                deleteKey.keyStyle = .deleteKey
                addSubview(deleteKey)
                
                let resignKey = TNKeyboardButton(frame: CGRect(x: keySpacing, y: y + keySpacing, width: keyHeight + 2 * keySpacing, height: keyHeight - 2 * keySpacing))
                resignKey.keyStyle = .returnStyle
                addSubview(resignKey)
            }
            y += keyHeight + rowSpacing
        }
        
    }
}

