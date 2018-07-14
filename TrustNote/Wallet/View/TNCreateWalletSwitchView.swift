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
    @IBOutlet weak var leftViewWidthConstranit: NSLayoutConstraint!
    @IBOutlet weak var rightViewWidthConstranit: NSLayoutConstraint!
    var selectedBtn: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonBtn.setTitle("Common wallet".localized, for: .normal)
        observBtn.setTitle("Observe wallet".localized, for: .normal)
        selectedBtn = commonBtn
        if TNLocalizationTool.shared.currentLanguage == "en" {
            commonBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            observBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            leftViewWidthConstranit.constant = UILabel.textSize(text: "Regular wallet", font: UIFont.systemFont(ofSize: 14), maxSize: CGSize(width: kScreenW, height: 44)).width + 5
            rightViewWidthConstranit.constant = UILabel.textSize(text: "Watch-Only wallet", font: UIFont.systemFont(ofSize: 14), maxSize: CGSize(width: kScreenW, height: 44)).width + 5
        }
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
        
        guard sender == commonBtn else {
            MBProgress_TNExtension.showViewAfterSecond(title: "暂不支持此功能")
            return
        }
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
