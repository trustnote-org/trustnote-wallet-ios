//
//  TNWalletCell.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/16.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNWalletCell: UITableViewCell {

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var decimalLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var model: TNWalletModel? {
        didSet{
            nameLabel.text = model?.walletName
            typeLabel.isHidden = (model?.isLocal)! ? true : false
            let totalAmount: String = (model?.balance)!
            let offsetIndex: String.Index = totalAmount.index(totalAmount.endIndex, offsetBy: -4)
            let offsetRange1 = totalAmount.startIndex ..< offsetIndex
            balanceLabel.text = String(totalAmount[offsetRange1])
            let offsetRange2 = offsetIndex ..< totalAmount.endIndex
            decimalLabel.text = String(totalAmount[offsetRange2])
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        typeLabel.layer.cornerRadius = kCornerRadius
        typeLabel.layer.masksToBounds = true
        typeLabel.layer.borderColor = UIColor.hexColor(rgbValue: 0xF6782F).cgColor
        typeLabel.layer.borderWidth = 1.0
    }
}
