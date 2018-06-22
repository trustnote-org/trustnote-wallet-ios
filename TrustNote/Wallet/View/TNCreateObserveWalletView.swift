//
//  TNCreateObserveWalletView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/18.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNCreateObserveWalletView: UIView {
    
    typealias ClickedScanButtonBlock = () -> Void
    typealias ClickedImportButtonBlock = () -> Void
    
    var clickedScanButtonBlock: ClickedScanButtonBlock?
    var clickedImportButtonBlock: ClickedImportButtonBlock?
    
    @IBOutlet weak var lineViewTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var identLabel: UILabel!
    @IBOutlet weak var tipViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var saoButton: UIButton!
    @IBOutlet weak var identCodeLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var firstTipLabel: UILabel!
    @IBOutlet weak var lastTipLabel: UILabel!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var invalidImgview: UIImageView!
    @IBOutlet weak var invalidLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        firstTipLabel.attributedText = firstTipLabel.getAttributeStringWithString(NSLocalizedString("CreateObserveWallet.firstTip", comment: ""), lineSpace: 5.0)
        lastTipLabel.attributedText = lastTipLabel.getAttributeStringWithString(NSLocalizedString("CreateObserveWallet.lastTip", comment: ""), lineSpace: 5.0)
        let fontSize = CGSize(width: kScreenW - 83, height: CGFloat(MAXFLOAT))
        let firstSize = UILabel.textSize(text: NSLocalizedString("Password.firstWarning", comment: ""), font: firstTipLabel.font, maxSize: fontSize)
        let lastSize = UILabel.textSize(text: NSLocalizedString("Password.secondWarning", comment: ""), font: firstTipLabel.font, maxSize: fontSize)
        tipViewHeightConstraint.constant = firstSize.height + lastSize.height + 60
        
        importButton.layer.cornerRadius = kCornerRadius
        importButton.layer.masksToBounds = true
    }
   
}

extension TNCreateObserveWalletView {
    
    @IBAction func importAction(_ sender: Any) {
        if let clickedImportButtonBlock = clickedImportButtonBlock {
            clickedImportButtonBlock()
        }
    }
    
    @IBAction func checkAction(_ sender: Any) {
        
    }
    
    @IBAction func scanAction(_ sender: Any) {
        if let clickedScanButtonBlock = clickedScanButtonBlock {
            clickedScanButtonBlock()
        }
    }
}

extension TNCreateObserveWalletView: TNNibLoadable {
    
    class func createObserveWalletView() -> TNCreateObserveWalletView {
        
        return TNCreateObserveWalletView.loadViewFromNib()
    }
}
