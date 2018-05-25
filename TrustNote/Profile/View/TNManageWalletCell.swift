//
//  TNManageWalletCell.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/25.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNManageWalletCell: UITableViewCell, RegisterCellFromNib {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var assertLabel: UILabel!
    @IBOutlet weak var decimalLabel: UILabel!
    
    var walletModel: TNWalletModel? {
        didSet {
            walletNameLabel.text = walletModel?.walletName
            markLabel.isHidden = (walletModel?.isLocal)! ? true : false
            let length = walletModel?.balance.length
            assertLabel.text = walletModel?.balance.substring(toIndex: length! - 4)
            decimalLabel.text = walletModel?.balance.substring(fromIndex: length! - 4)
            if let walletId = walletModel?.walletId {
                 queryWallet(walletId)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = kCornerRadius
        containerView.layer.shadowColor = UIColor.hexColor(rgbValue: 0xD4E0F1).cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8.0)
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowRadius = 10.0
        markLabel.layer.borderColor = UIColor.hexColor(rgbValue: 0xF6782F).cgColor
        markLabel.layer.borderWidth = 1.0
    }
    
    @IBAction func selectAction(_ sender: Any) {
        
    }
    
    private func queryWallet(_ walletId: String) {
        let sql = "SELECT address FROM my_addresses WHERE wallet=? AND is_change=0 AND address_index=0"
        TNSQLiteManager.sharedManager.queryFirstWalletAddress(sql: sql, walletId: walletId) {[unowned self] (addresses) in
            guard !addresses.isEmpty else {
                return
            }
            let address = addresses.first!
            let length = address.length
            if length > 16 {
                let frontPartStr = address.substring(toIndex: 8)
                let backPartStr = address.substring(fromIndex: length - 8)
                self.addressLabel.text = frontPartStr + "..." + backPartStr
            }
        }
    }
}
