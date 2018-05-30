//
//  TNDeleteWalletAlertView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/26.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNDeleteWalletAlertView: UIView, TNNibLoadable {

    typealias ClickedButtonBlock = () -> Void
  
    var didClickedConfirmBlock: ClickedButtonBlock?
    var didClickedCancelBlock: ClickedButtonBlock?
    
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupRadiusCorner(radius: kCornerRadius * 2)
        layer.shadowColor = kGlobalColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 20.0
        confirmBtn.setTitle(NSLocalizedString("Confirm", comment: ""), for: .normal)
        cancelBtn.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        descLabel.text = NSLocalizedString("Delete the wallet warning", comment: "")
        confirmBtn.setupRadiusCorner(radius: kCornerRadius)
        cancelBtn.setupRadiusCorner(radius: kCornerRadius)
        cancelBtn.layer.borderWidth = 1.0
        cancelBtn.layer.borderColor = kGlobalColor.cgColor
    }
   
}

extension TNDeleteWalletAlertView {
    
    @IBAction func cancelAction(_ sender: Any) {
        didClickedCancelBlock?()
    }
    
    @IBAction func confirmAction(_ sender: Any) {
       didClickedConfirmBlock?()
    }
}
