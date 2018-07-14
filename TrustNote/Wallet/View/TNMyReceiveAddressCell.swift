//
//  TNMyReceiveAddressCell.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/3.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNMyReceiveAddressCell: UITableViewCell, RegisterCellFromNib {
    
    @IBOutlet weak var amountLabel: TNVerticalAlignLabel!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var copyBtn: UIButton!
    @IBOutlet weak var setAmountBtn: UIButton!
    @IBOutlet weak var codeImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var copyBtnLeftConstraint: NSLayoutConstraint!
    
    var setupRecievedAmountBlock: (() -> Void)?
    
    var clearAmountBlock: (() -> Void)?
    
    var amount: Int64 = 0
    
    var recievedAddress = ""
    
    var wallet: TNWalletModel? {
        didSet {
            let sql = "SELECT address FROM my_addresses WHERE wallet=? AND is_change=?"
            TNSQLiteManager.sharedManager.queryWalletAddress(sql: sql, walletId: wallet!.walletId, isChange: 0) {[unowned self] (results) in
                guard !results.isEmpty else {
                    return
                }
                self.addressLabel.text = results.first
                self.recievedAddress = results.first!
                let imgSize = self.codeImageView.size
                var inputMsg = TNScanPrefix + results.first!
                if self.amount > 0{
                    inputMsg.append("?amount=" + String(self.amount))
                }
                DispatchQueue.global().async {
                    let qrImage = UIImage.createHDQRImage(input: inputMsg, imgSize: imgSize)
                    DispatchQueue.main.async(execute: {
                        self.codeImageView.image = qrImage
                    })
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupRadiusCorner(radius: kCornerRadius * 2)
        //setupShadow(Offset: CGSize(width: 0, height: 2), opacity: 0.2, radius: 10)
        layer.masksToBounds = true
        copyBtn.setupRadiusCorner(radius: kCornerRadius)
        containerView.layer.borderColor = UIColor.hexColor(rgbValue: 0xF2F2F2).cgColor
        containerView.layer.borderWidth = kCornerRadius
        titleLabel.text = "My receiving address".localized
        setAmountBtn.setTitle("Fixed amount".localized, for: .normal)
        copyBtn.setTitle("Copy the receiving address".localized, for: .normal)
        clearBtn.setTitle("Clear the amount".localized + "(MN)", for: .normal)
        amountLabel.verticalAlignment = VerticalAlignmentBottom
        copyBtnLeftConstraint.constant = IS_iphone5 ? 20 : 30
    }
}

extension TNMyReceiveAddressCell {
    
    @IBAction func clearAmount(_ sender: Any) {
        clearAmountBlock?()
    }
    
    @IBAction func copyRecievedAddress(_ sender: Any) {
        guard !recievedAddress.isEmpty else {
            return
        }
        UIPasteboard.general.string = recievedAddress
        let customView = UIImageView(image: UIImage(named: "profile_success"))
        MBProgress_TNExtension.showAlertMessage(alertMessage: "Copy success".localized, customView: customView)
    }
    
    @IBAction func setupRecievedAmount(_ sender: Any) {
        setupRecievedAmountBlock?()
    }
}
