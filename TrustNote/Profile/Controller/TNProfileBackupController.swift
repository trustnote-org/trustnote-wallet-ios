//
//  TNProfileBackupController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/31.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import pop

class TNProfileBackupController: TNNavigationController {

    let kContentY: CGFloat = kNavBarHeight + CGFloat(100 * scale)
    private let textLabel = UILabel().then {
        $0.textColor = kTitleTextColor
        $0.font = kTitleFont
        $0.text = "Backup mnemonic".localized
    }
    
    private let titleView = UIView().then {
        $0.backgroundColor = UIColor.white
    }
    
    fileprivate lazy var profileBackupHeadView: TNProfileBackupHeadView = {
        let profileBackupHeadView = TNProfileBackupHeadView.profileBackupHeadView()
        return profileBackupHeadView
    }()
    
    fileprivate lazy var didDeleteMnemonicView: TNDidDeleteMnemonicView = {
        let didDeleteMnemonicView = TNDidDeleteMnemonicView.didDeleteMnemonicView()
        didDeleteMnemonicView.isHidden = true
        return didDeleteMnemonicView
    }()
    
    fileprivate lazy var contentView: TNProfileBackupContentView = {
        let contentView = TNProfileBackupContentView(frame: CGRect(x: 0, y:  kContentY, width: kScreenW, height: kScreenH -  kContentY))
        return contentView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        layoutAllSubviews()
        let profile = TNConfigFileManager.sharedInstance.readProfileFile()
        let mnemonic = profile["mnemonic"] as! String
        if mnemonic.isEmpty {
            didDeleteMnemonicView.isHidden = false
            view.bringSubview(toFront: didDeleteMnemonicView)
        } else {
            view.insertSubview(contentView, belowSubview: navigationBar)
        }
        
        profileBackupHeadView.profileBackupHeadViewBlock = {[unowned self] (isShow, animated) in
            let contentViewY = isShow ? self.kContentY : self.kContentY - (kScreenH -  self.kContentY)
            if animated {
                UIView.animate(withDuration: 0.3, animations: {
                    self.contentView.y = contentViewY
                })
            } else {
                self.contentView.y = contentViewY
            }
        }
        
        profileBackupHeadView.showMnemonic(isShow: profileBackupHeadView.isShow, animated: false)
        
        contentView.profileDeleteMnemonicBlock = {[unowned self] in
            self.alertAction(self, "Make sure delete words".localized, message: nil, sureActionText: "Confirm".localized, cancelActionText: "Cancel".localized, isChange: true) {
                TNConfigFileManager.sharedInstance.updateProfile(key: "mnemonic", value: "")
                TNGlobalHelper.shared.mnemonic = ""
                self.didDeleteMnemonicView.isHidden = false
                self.view.bringSubview(toFront: self.didDeleteMnemonicView)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = kBackgroundColor
    }
}

extension TNProfileBackupController {
    
    fileprivate func layoutAllSubviews() {
        
        view.addSubview(didDeleteMnemonicView)
        didDeleteMnemonicView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navigationBar.snp.bottom)
        }
        
        view.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(50 * scale)
        }
        
        titleView.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(9)
            make.left.equalToSuperview().offset(kLeftMargin)
        }
        
        view.addSubview(profileBackupHeadView)
        profileBackupHeadView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleView.snp.bottom)
            make.height.equalTo(50 * scale)
        }
    }
}
