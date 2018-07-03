//
//  TNTradeRecordCell.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/20.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNTradeRecordCell: UITableViewCell, RegisterCellFromNib {

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var decimalLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    var model: TNTransactionRecord? {
        didSet {
            if let model = model {
                transactionType = model.action
                let formatterTime = NSDate.getFormatterTime(timeStamp: String(model.time), formatter: "MM-dd HH:mm")
                dateLabel.text = formatterTime
            }
        }
    }
    
    var transactionType: TNTransactionAction? {
        didSet {
            if let transactionType = transactionType {
                var showAddress = ""
                var imgName = ""
                switch transactionType {
                case .invalid:
                    amountLabel.textColor = kTitleTextColor
                    decimalLabel.textColor = kTitleTextColor
                    imgName = "send_invalid"
                case .move:
                    showAddress = model!.addressTo!
                    amountLabel.textColor = kTitleTextColor
                    decimalLabel.textColor = kTitleTextColor
                case .received:
                    showAddress = model!.arrPayerAddresses.first!
                    amountLabel.textColor = kGlobalColor
                    decimalLabel.textColor = kGlobalColor
                    imgName = model!.confirmations ? "recieve_confirmed" : "recieve_unconfirmed"
                case .sent:
                    showAddress = model!.addressTo!
                    amountLabel.textColor = kTitleTextColor
                    decimalLabel.textColor = kTitleTextColor
                    imgName = model!.confirmations ? "send_confirmed" : "send_unconfirmed"
                }
                iconView.image = UIImage(named: imgName)
                let frontPart = showAddress.substring(toIndex: 5)
                let backPart = showAddress.substring(fromIndex: showAddress.length - 3)
                addressLabel.text = frontPart + "..." + backPart
                let realAmount = Double((model?.amount)!) / kBaseOrder
                let assert = String(format: "%.4f", realAmount)
                let sign = transactionType == .received ? "+" : "-"
                amountLabel.text = sign + assert.substring(toIndex: assert.length - TNGlobalHelper.shared.unitDecimals)
                decimalLabel.text = assert.substring(fromIndex: assert.length - TNGlobalHelper.shared.unitDecimals)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
