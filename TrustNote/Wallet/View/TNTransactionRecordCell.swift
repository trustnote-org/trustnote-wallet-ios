//
//  TNTransactionRecordCell.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/5.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNTransactionRecordCell: UITableViewCell {

    @IBOutlet weak var labelCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var transactionType: TNTransactionAction? {
        didSet {
            if let transactionType = transactionType {
                switch transactionType {
                case .invalid:
                    break
                case .move:
                    labelCenterYConstraint.constant = -12.0
                    typeLabel.backgroundColor = UIColor.orange
                    let realAmount = Double((model?.amount)!) / 1000000.0
                    amountLabel.text =  String(format: "%.5f", realAmount) + " MN"
                case .received:
                    labelCenterYConstraint.constant = 0
                    typeLabel.backgroundColor = UIColor.blue
                    let realAmount = Double((model?.amount)!) / 1000000.0
                    amountLabel.text =  "+ " + String(format: "%.5f", realAmount) + " MN"
                case .sent:
                    labelCenterYConstraint.constant = -12.0
                    typeLabel.backgroundColor = UIColor.gray
                    let realAmount = Double((model?.amount)!) / 1000000.0
                    amountLabel.text =  "- " + String(format: "%.5f", realAmount) + " MN"
                }
                typeLabel.text = transactionType.rawValue
            }
        }
    }
    
    var model: TNTransactionRecord? {
        didSet {
            if let model = model {
                transactionType = model.action
                addressLabel.text = "To: " + "\(model.addressTo ?? "")"
                addressLabel.isHidden = transactionType == .received ? true : false
                timeLabel.text = NSDate.compareDateTime(timeStamp: model.time)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        typeLabel.layer.cornerRadius = 3.0
        typeLabel.layer.masksToBounds = true
    }
    
}
