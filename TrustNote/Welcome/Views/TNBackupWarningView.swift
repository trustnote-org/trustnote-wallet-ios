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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        firstWarningLabel.attributedText = firstWarningLabel.getAttributeStringWithString(NSLocalizedString("Backup.firstWarning", comment: ""), lineSpace: 5.0)
        lastWarningLabel.attributedText = lastWarningLabel.getAttributeStringWithString(NSLocalizedString("Backup.lastWarning", comment: ""), lineSpace: 5.0)
        let fontSize = CGSize(width: kScreenW - 83, height: CGFloat(MAXFLOAT))
        let firstSize = firstWarningLabel.textSize(text: NSLocalizedString("Backup.firstWarning", comment: ""), font: firstWarningLabel.font, maxSize: fontSize)
        let lastSize = lastWarningLabel.textSize(text: NSLocalizedString("Backup.lastWarning", comment: ""), font: firstWarningLabel.font, maxSize: fontSize)
        dynamicHeight = firstSize.height + lastSize.height + 44
    }
}

/// MARK: load nib
extension TNBackupWarningView: TNNibLoadable {
    
    static func backupWarningView() -> TNBackupWarningView {
        
        return TNBackupWarningView.loadViewFromNib()
    }
}
