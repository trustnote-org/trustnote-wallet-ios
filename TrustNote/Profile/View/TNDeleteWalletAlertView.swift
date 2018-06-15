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
        setupShadow(Offset: CGSize(width: 0, height: 2.0), opacity: 0.2, radius: 20)
        confirmBtn.setTitle("Confirm".localized, for: .normal)
        cancelBtn.setTitle("Cancel".localized, for: .normal)
        descLabel.text = "Delete the wallet warning".localized
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
