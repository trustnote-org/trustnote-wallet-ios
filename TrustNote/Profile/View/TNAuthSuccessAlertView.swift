//
//  TNAuthSuccessAlertView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/30.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNAuthSuccessAlertView: UIView {

    typealias ClickedDoneButtonBlock = () -> Void
    
    var clickedDoneButtonBlock: ClickedDoneButtonBlock?
    
    var dismissBlock: ClickedDismissButtonBlock?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var codeImageView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doneBtn.setupRadiusCorner(radius: kCornerRadius)
        containerView.layer.borderColor = UIColor.hexColor(rgbValue: 0xF2F2F2).cgColor
        containerView.layer.borderWidth = kCornerRadius
        titleLabel.text = "Signing succeed".localized
        descLabel.text = "Scan auth success description".localized
        doneBtn.setTitle("Done".localized, for: .normal)
    }
    
}

extension TNAuthSuccessAlertView {
    
    @IBAction func dismissAction(_ sender: Any) {
        dismissBlock?()
    }
    
    @IBAction func doneAction(_ sender: Any) {
        clickedDoneButtonBlock?()
    }
}

extension TNAuthSuccessAlertView: TNNibLoadable {
    
    class func authSuccessAlertView() -> TNAuthSuccessAlertView {
        
        return TNAuthSuccessAlertView.loadViewFromNib()
    }
}
