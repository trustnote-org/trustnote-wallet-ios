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
            let assert = String(format: "%.4f",  Double((detailModel?.amount!)!) / 1000000.0)
            let assertStr = assert.substring(toIndex: assert.length - 4)
            if detailModel?.action?.rawValue == "RECEIVED" {
                assertLabel.text = "+" + assertStr
                assertLabel.textColor = kGlobalColor
                decimalLabel.textColor = kGlobalColor
                descLabel.text = "已收到(MN)"
            } else {
                assertLabel.text = "-" + assertStr
                assertLabel.textColor = kThemeTextColor
                decimalLabel.textColor = kThemeTextColor
                 descLabel.text = "已发送(MN)"
            }
            
            decimalLabel.text = assert.substring(fromIndex: assert.length - 4)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        frameView.layer.cornerRadius = kCornerRadius * 2
        frameView.layer.masksToBounds = true
    }
}

extension TNTradeDetailHeaderView : TNNibLoadable {
    
    class func tradeDetailHeaderView() -> TNTradeDetailHeaderView {
        
        return TNTradeDetailHeaderView.loadViewFromNib()
    }
}
