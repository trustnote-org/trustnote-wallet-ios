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
    
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var manageBtn: UIButton!
    @IBOutlet weak var lnitialsLabel: UILabel!
    
    weak var delegate: TNProfileHeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = kCornerRadius
        containerView.layer.masksToBounds = true
        checkBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        checkBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0)
        manageBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        manageBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0)
        lnitialsLabel.layer.cornerRadius = 25
        lnitialsLabel.layer.masksToBounds = true
        let defaultConfig = TNConfigFileManager.sharedInstance.readConfigFile()
        let deviceName = defaultConfig["deviceName"] as? String
        nameLabel.text = deviceName
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
