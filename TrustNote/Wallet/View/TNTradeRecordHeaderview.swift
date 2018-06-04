//
//  TNTradeRecordHeaderview.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/20.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNTradeRecordHeaderview: UIView {

    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var decimalLabel: UILabel!
    @IBOutlet weak var assertLabel: UILabel!
    var walletModel: TNWalletModel? {
        didSet {
            let totalAmount: String = ( walletModel?.balance)!
            let offsetIndex: String.Index = totalAmount.index(totalAmount.endIndex, offsetBy: -4)
            let offsetRange1 = totalAmount.startIndex ..< offsetIndex
            assertLabel.text = String(totalAmount[offsetRange1])
            let offsetRange2 = offsetIndex ..< totalAmount.endIndex
            decimalLabel.text = String(totalAmount[offsetRange2])
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unitLabel.text = "Total assets".localized + " (MN)"
    }
}

extension TNTradeRecordHeaderview: TNNibLoadable {
    
    class func tradeRecordHeaderview() -> TNTradeRecordHeaderview {
        
        return TNTradeRecordHeaderview.loadViewFromNib()
    }
}
