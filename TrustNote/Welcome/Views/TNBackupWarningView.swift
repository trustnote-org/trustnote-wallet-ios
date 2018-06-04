//
//  TNBackupWarningView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/9.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNBackupWarningView: UIView {

    @IBOutlet weak var firstWarningLabel: UILabel!
    @IBOutlet weak var lastWarningLabel: UILabel!
    
    var dynamicHeight: CGFloat = 0.0
    
    var tips: [String]? {
        didSet{
            firstWarningLabel.attributedText = firstWarningLabel.getAttributeStringWithString(tips!.first!, lineSpace: 3.0)
            lastWarningLabel.attributedText = lastWarningLabel.getAttributeStringWithString(tips!.last!, lineSpace: 3.0)
            let fontSize = CGSize(width: kScreenW - 83, height: CGFloat(MAXFLOAT))
            let firstSize = firstWarningLabel.textSize(text: tips!.first!, font: firstWarningLabel.font, maxSize: fontSize)
            let lastSize = lastWarningLabel.textSize(text: tips!.last!, font: firstWarningLabel.font, maxSize: fontSize)
            dynamicHeight = firstSize.height + lastSize.height + 30
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if IS_iphone5 {
            firstWarningLabel.font = UIFont.systemFont(ofSize: 13)
            lastWarningLabel.font = UIFont.systemFont(ofSize: 13)
        }
    }
}

/// MARK: load nib
extension TNBackupWarningView: TNNibLoadable {
    
    static func backupWarningView() -> TNBackupWarningView {
        
        return TNBackupWarningView.loadViewFromNib()
    }
}
