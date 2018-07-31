//
//  TNProtocolViewCell.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/23.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNProtocolViewCell: UITableViewCell, RegisterCellFromNib {

    
    @IBOutlet weak var contentLabel: UILabel!
    
    var content: String? {
        didSet {
            let attributedString = NSMutableAttributedString(string: content!.localized)
            let paragraphStye = NSMutableParagraphStyle()
            paragraphStye.lineSpacing = 5
            let rang = NSMakeRange(0, CFStringGetLength(content!.localized as CFString?))
            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStye, range: rang)
            contentLabel.attributedText = attributedString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        //drawRoundView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
