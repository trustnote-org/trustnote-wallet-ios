//
//  TNTradeRecordCell.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/20.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNTradeRecordCell: UITableViewCell {

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var decimalLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    var model: TNTransactionRecord? {
        didSet {
            if let model = model {
                transactionType = model.action
                let formatterTime = NSDate.getFormatterTime(timeStamp: String(model.time), formatter: "yyyy-MM-dd HH:mm:ss")
                let timeArr = formatterTime.components(separatedBy: " ")
                let frontPart = timeArr.first?.substring(fromIndex: 5)
                let backPart = timeArr.last?.substring(toIndex: 5)
                dateLabel.text = frontPart! + "  " + backPart!
            }
        }
    }
    
    var transactionType: TNTransactionAction? {
        didSet {
            if let transactionType = transactionType {
                var showAddress = ""
                switch transactionType {
                case .invalid:
                    break
                case .move:
                    showAddress = (model?.addressTo!)!
                    amountLabel.textColor = UIColor.hexColor(rgbValue: 0xE33B1B)
                    decimalLabel.textColor = UIColor.hexColor(rgbValue: 0xE33B1B)
                case .received:
                    showAddress = (model?.arrPayerAddresses.first)!
                    amountLabel.textColor = kGlobalColor
                    decimalLabel.textColor = kGlobalColor
                case .sent:
                    showAddress = (model?.addressTo!)!
                    amountLabel.textColor = UIColor.hexColor(rgbValue: 0xE33B1B)
                    decimalLabel.textColor = UIColor.hexColor(rgbValue: 0xE33B1B)
                }
                let frontPart = showAddress.substring(toIndex: 5)
                let backPart = showAddress.substring(fromIndex: showAddress.length - 3)
                addressLabel.text = frontPart + "..." + backPart
                let realAmount = Double((model?.amount)!) / 1000000.0
                let assert = String(format: "%.4f", realAmount)
                let sign = transactionType == .received ? "+" : "-"
                amountLabel.text = sign + assert.substring(toIndex: assert.length - 4)
                decimalLabel.text = assert.substring(fromIndex: assert.length - 4)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
