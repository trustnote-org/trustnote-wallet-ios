//
//  TNTotalAssertView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/7/19.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNTotalAssertView: UIView {

    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var decimalLabel: UILabel!
    var totalAssert: Double? {
        didSet {
            let totalAmount = String(format: "%.4f", totalAssert!)
            let offsetIndex: String.Index = totalAmount.index(totalAmount.endIndex, offsetBy: -4)
            let offsetRange1 = totalAmount.startIndex ..< offsetIndex
            totalAmountLabel.text = String(totalAmount[offsetRange1])
            let offsetRange2 = offsetIndex ..< totalAmount.endIndex
            decimalLabel.text = String(totalAmount[offsetRange2])
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        unitLabel.text = "Total assets".localized + " (MN)"
    }
}

extension TNTotalAssertView: TNNibLoadable {
    
    class func totalAssertView() -> TNTotalAssertView {
        
        return TNTotalAssertView.loadViewFromNib()
    }
}

