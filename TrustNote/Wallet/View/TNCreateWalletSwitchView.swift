//
//  TNCreateWalletSwitchView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/18.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

protocol TNCreateWalletSwitchViewDelegate: NSObjectProtocol {
    func didClickedCommonWalletBtn()
    func didClickedObservWalletBtn()
}

class TNCreateWalletSwitchView: UIView {
    
    weak var delegate: TNCreateWalletSwitchViewDelegate?
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var commonBtn: UIButton!
    @IBOutlet weak var leftLine: UIView!
    @IBOutlet weak var observBtn: UIButton!
    @IBOutlet weak var rightLine: UIView!
    var selectedBtn: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonBtn.setTitle(NSLocalizedString("Common wallet", comment: ""), for: .normal)
        observBtn.setTitle(NSLocalizedString("Observe wallet", comment: ""), for: .normal)
        selectedBtn = commonBtn
    }
    
    @IBAction func switchAction(_ sender: UIButton) {
        switchCreateWalletStyle(sender, isCallBack: true)
    }
    
    func shouldSelelctCommonWalletButton(isSelected: Bool) {
        if isSelected {
            switchCreateWalletStyle(commonBtn, isCallBack: false)
        } else {
            switchCreateWalletStyle(observBtn, isCallBack: false)
        }
    }
    
    func switchCreateWalletStyle(_ sender: UIButton, isCallBack: Bool) {
        if sender != selectedBtn {
            if sender == commonBtn {
                commonBtn.setTitleColor(kGlobalColor, for: .normal)
                leftLine.isHidden = false
                observBtn.setTitleColor(UIColor.hexColor(rgbValue: 0x4B5461), for: .normal)
                rightLine.isHidden = true
                if isCallBack {
                   delegate?.didClickedCommonWalletBtn()
                }
            } else {
                observBtn.setTitleColor(kGlobalColor, for: .normal)
                rightLine.isHidden = false
                commonBtn.setTitleColor(UIColor.hexColor(rgbValue: 0x4B5461), for: .normal)
                leftLine.isHidden = true
                if isCallBack {
                   delegate?.didClickedObservWalletBtn()
                }
            }
            selectedBtn = sender
        }
    }
}

extension TNCreateWalletSwitchView: TNNibLoadable {
    
    class func createWalletSwitchView() -> TNCreateWalletSwitchView {
        
        return TNCreateWalletSwitchView.loadViewFromNib()
    }
}
