//
//  TNTradeDetailHeaderView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/23.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNTradeDetailHeaderView: UIView {
    
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var assertLabel: UILabel!
    @IBOutlet weak var decimalLabel: UILabel!
    @IBOutlet weak var frameView: UIView!
    
    var detailModel: TNTransactionRecord? {
        didSet {
            let assert = String(format: "%.4f",  Double((detailModel?.amount!)!) / kBaseOrder)
            let assertStr = assert.substring(toIndex: assert.length - TNGlobalHelper.shared.unitDecimals)
            if detailModel?.action?.rawValue == "RECEIVED" {
                assertLabel.text = "+" + assertStr
                assertLabel.textColor = kGlobalColor
                decimalLabel.textColor = kGlobalColor
                descLabel.text = "Received".localized + "(MN)"
            } else {
                assertLabel.text = "-" + assertStr
                assertLabel.textColor = kThemeTextColor
                decimalLabel.textColor = kThemeTextColor
                descLabel.text = "Sent".localized + "(MN)"
            }
            
            decimalLabel.text = assert.substring(fromIndex: assert.length - TNGlobalHelper.shared.unitDecimals)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        frameView.layer.cornerRadius = kCornerRadius * 2
        titleTextLabel.text = "Transaction Details".localized
        setupShadow(Offset: CGSize(width: 0, height: 6), opacity: 0.08, radius: 6.0)
    }
}

extension TNTradeDetailHeaderView: TNNibLoadable {
    
    class func tradeDetailHeaderView() -> TNTradeDetailHeaderView {
        
        return TNTradeDetailHeaderView.loadViewFromNib()
    }
}
