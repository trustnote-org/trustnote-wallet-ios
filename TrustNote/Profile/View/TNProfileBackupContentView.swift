//
//  TNProfileBackupContentView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/1.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNProfileBackupContentView: UIView {
    
    let bottomPadding = IS_iPhoneX ? (kSafeAreaBottomH + 26) : CGFloat(26 * scale)
    
    var profileDeleteMnemonicBlock: (() -> Void)?
    
    private let textLabel = UILabel().then {
        $0.textColor = kThemeTextColor
        $0.font = UIFont(name: "PingFangSC-Medium", size: TNLocalizationTool.shared.currentLanguage == "en" ? 17 : 18)
        $0.text = "Backup your 12 words mnemonic now".localized
    }
    
    private let descLabel = UILabel().then {
        $0.textColor = kThemeTextColor
        $0.numberOfLines = 0
        $0.font = UIFont(name: "PingFangSC-Light", size: 14)
        $0.text = "Backup.description".localized
    }
    
    fileprivate lazy var seedView: TNBackupSeedBackView = {
        let seedView = TNBackupSeedBackView.backupSeedBackView()
        seedView.seedContainerView.isCanEdit = false
        return seedView
    }()
    
    fileprivate lazy var warningView: TNBackupWarningView = {
        let warningView = TNBackupWarningView.backupWarningView()
        warningView.setupRadiusCorner(radius: kCornerRadius)
        warningView.tips = ["Backup.firstWarning".localized, "Backup.lastWarning".localized]
        return warningView
    }()
    
    private let deleteButton = TNButton().then {

        $0.setTitle("Delete words".localized, for: .normal)
        $0.setTitleColor(kGlobalColor, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        $0.layer.borderColor = kGlobalColor.cgColor
        $0.layer.borderWidth = 1.0
        $0.setupRadiusCorner(radius: kCornerRadius)
        $0.addTarget(self, action: #selector(TNProfileBackupContentView.deleteMnemonic), for: .touchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        let profile = TNConfigFileManager.sharedInstance.readProfileFile()
        let mnemonic = profile["mnemonic"] as! String
        if !mnemonic.isEmpty {
            seedView.seedContainerView.mnmnemonicsArr = mnemonic.components(separatedBy: " ")
        }
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension TNProfileBackupContentView {
    
    fileprivate func addSubviews() {
        addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kLeftMargin)
            make.top.equalToSuperview().offset(22)
            make.centerX.equalToSuperview()
        }
        
        addSubview(descLabel)
        descLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kLeftMargin)
            make.top.equalTo(textLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        addSubview(seedView)
        seedView.snp.makeConstraints { (make) in
            make.left.equalTo(descLabel.snp.left)
            make.centerX.equalToSuperview()
            make.top.equalTo(descLabel.snp.bottom).offset(20  * scale)
            make.height.equalTo(142)
        }
        
        addSubview(deleteButton)
        deleteButton.snp.makeConstraints { (make) in
            make.left.equalTo(seedView.snp.left)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-bottomPadding)
            make.height.equalTo(48 * scale)
        }
        
        addSubview(warningView)
        warningView.snp.makeConstraints { (make) in
            make.left.equalTo(seedView.snp.left)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(deleteButton.snp.top).offset(-24  * scale)
            make.height.equalTo(warningView.dynamicHeight)
        }
    }
}

extension TNProfileBackupContentView {
    
    @objc fileprivate func deleteMnemonic() {
        profileDeleteMnemonicBlock?()
    }
}
