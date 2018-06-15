//
//  TNManageWalletCell.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/25.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

 let Button_Tag_Begin = 100

class TNManageWalletCell: UITableViewCell, RegisterCellFromNib {
    
    let Button_Tag_Begin = 100
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var assertLabel: UILabel!
    @IBOutlet weak var decimalLabel: UILabel!
    @IBOutlet weak var touchBtn: UIButton!
    
    var getFirstAddressBlock: ((String) -> Void)?
    
    var checkoutWalletDetailBlock: ((Int) -> Void)?
    
    var walletModel: TNWalletModel? {
        didSet {
            walletNameLabel.text = walletModel?.walletName
            markLabel.isHidden = (walletModel?.isLocal)! ? true : false
            let length = walletModel?.balance.length
            assertLabel.text = walletModel?.balance.substring(toIndex: length! - TNGlobalHelper.shared.unitDecimals)
            decimalLabel.text = walletModel?.balance.substring(fromIndex: length! - TNGlobalHelper.shared.unitDecimals)
            if let walletId = walletModel?.walletId {
                 queryWallet(walletId)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        containerView.layer.cornerRadius = kCornerRadius
        containerView.setupShadow(Offset: CGSize(width: 0, height: 8.0), opacity: 0.2, radius: 10)
        markLabel.layer.borderColor = kThemeMarkColor.cgColor
        markLabel.layer.borderWidth = 1.0
        markLabel.setupRadiusCorner(radius: kCornerRadius)
    }
    
    @IBAction func selectAction(_ sender: UIButton) {
        checkoutWalletDetailBlock?(sender.tag - Button_Tag_Begin)
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
            self.getFirstAddressBlock?(address)
        }
    }
}
