//
//  TNProfileHeaderView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/24.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

protocol TNProfileHeaderViewDelegate: NSObjectProtocol {
    func didClickedEditButton()
    func didClickedManageWalletButton()
    func didClickedCheckTransactionButton()
}

class TNProfileHeaderView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var containerLeftMarginConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var manageBtn: UIButton!
    @IBOutlet weak var lnitialsLabel: UILabel!
    
    weak var delegate: TNProfileHeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = kCornerRadius
        containerView.setupShadow(Offset: CGSize(width: 0, height: 6), opacity: 0.08, radius: 6)
        containerLeftMarginConstraint.constant = IS_iphone5 ? 10 : 20
        if IS_iphone5 {
            descLabel.font = UIFont.systemFont(ofSize: 13)
        }
        descLabel.text = "Welcome to the TrustNote World".localized
        checkBtn.setTitle("Transaction records".localized, for: .normal)
        manageBtn.setTitle("Manage wallet".localized, for: .normal)
        if TNLocalizationTool.shared.currentLanguage == "en" {
            checkBtn.relayoutButton()
            manageBtn.relayoutButton()
        } else {
            checkBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
            checkBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0)
            manageBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
            manageBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0)
        }
        lnitialsLabel.layer.cornerRadius = 25
        lnitialsLabel.layer.masksToBounds = true
        let defaultConfig = TNConfigFileManager.sharedInstance.readConfigFile()
        let deviceName = defaultConfig["deviceName"] as? String
        if deviceName!.length <= 10 {
            nameLabel.text = deviceName
        } else {
            let frontStr = deviceName!.substring(toIndex: 5)
            let backStr = deviceName!.substring(fromIndex: deviceName!.length - 5)
            nameLabel.text = frontStr + "..." + backStr
        }
        lnitialsLabel.text = deviceName?.substring(toIndex: 1)
    }
   
}

extension TNProfileHeaderView {
   
    @IBAction func checkTransactionRecord(_ sender: Any) {
        delegate?.didClickedCheckTransactionButton()
    }
    
    @IBAction func manageWallet(_ sender: Any) {
        delegate?.didClickedManageWalletButton()
    }
    
    @IBAction func editInfo(_ sender: Any) {
        delegate?.didClickedEditButton()
    }
}

extension TNProfileHeaderView: TNNibLoadable {
    
    class func profileHeaderView() -> TNProfileHeaderView {
        
        return TNProfileHeaderView.loadViewFromNib()
    }
}

