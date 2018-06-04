//
//  TNVBackupsSeedController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/9.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNVBackupsSeedController: TNBaseViewController {
    
    let bottomPadding = IS_iPhoneX ? (kSafeAreaBottomH + 26) : 26
    
    private let backBtn = UIButton().then {
        $0.setImage(UIImage(named: "welcome_back"), for: .normal)
        $0.addTarget(self, action: #selector(TNVBackupsSeedController.goBack), for: .touchUpInside)
    }
    
    private let titleTextLabel = UILabel().then {
        $0.text =  NSLocalizedString("Backup Your Seed Phrase", comment: "")
        $0.textColor = kTitleTextColor
        $0.font = kTitleFont
    }
    
    private let detailLabel = UILabel().then {
        $0.text =  NSLocalizedString("Backup.detail", comment: "")
        $0.textColor = kThemeTextColor
        $0.font = kButtonFont
        $0.numberOfLines = 0
    }
    
    private let descLabel = UILabel().then {
        $0.text =  NSLocalizedString("Backup.description", comment: "")
        $0.textColor = kThemeTextColor
        $0.font = UIFont.systemFont(ofSize: 14.0)
        $0.numberOfLines = 0
    }
    
    private let doneButton = TNButton().then {
        $0.setBackgroundImage(UIImage.creatImageWithColor(color: kGlobalColor, viewSize: CGSize(width:  kScreenW, height: 48)), for: .normal)
        $0.setTitle(NSLocalizedString("Backup done", comment: ""), for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        $0.addTarget(self, action: #selector(TNVBackupsSeedController.backupCompleted), for: .touchUpInside)
    }
    
    fileprivate lazy var seedView: TNBackupSeedBackView = {
        let seedView = TNBackupSeedBackView.backupSeedBackView()
        return seedView
    }()
    
    fileprivate lazy var warningView: TNBackupWarningView = {
        let warningView = TNBackupWarningView.backupWarningView()
        warningView.setupRadiusCorner(radius: kCornerRadius)
        warningView.tips = ["Backup.firstWarning".localized, "Backup.lastWarning".localized]
        return warningView
    }()
    
    var isNeedAlert = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        layoutAllSubviews()
        seedView.seedContainerView.isCanEdit = false
        seedView.seedContainerView.mnmnemonicsArr = TNGlobalHelper.shared.mnemonic.components(separatedBy: " ")
        if TNGlobalHelper.shared.my_device_address.isEmpty {
            generateMyDeviceAddress()
        }
        if TNGlobalHelper.shared.xPubkey.isEmpty {
            generateRootPubkey()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if navigationController?.viewControllers.count == 3 {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        guard isNeedAlert else {
            return
        }
        alertAction(self, NSLocalizedString("Backup mode reminding", comment: ""), message: nil, sureActionText: nil, cancelActionText: NSLocalizedString("Confirm", comment: ""), isChange: false, sureAction: nil)
        isNeedAlert = false
    }
    
    override func viewDidDisappear(_ animated:Bool) {
        super.viewDidDisappear(animated)
        if navigationController?.viewControllers.count == 3 {
             navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
}

/// MARK: Subviews  Layout
extension TNVBackupsSeedController {
    
    fileprivate func layoutAllSubviews() {
        
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kLeftMargin * scale)
            make.top.equalToSuperview().offset(kStatusbarH)
            make.height.width.equalTo(44)
        }
        
        view.addSubview(titleTextLabel)
        titleTextLabel.snp.makeConstraints { (make) in
            make.left.equalTo(backBtn.snp.left)
            make.top.equalTo(backBtn.snp.bottom).offset(9 * scale)
        }
        
        view.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleTextLabel.snp.left)
            make.top.equalTo(titleTextLabel.snp.bottom).offset(32 * scale)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(descLabel)
        descLabel.snp.makeConstraints { (make) in
            make.left.equalTo(detailLabel.snp.left)
            make.top.equalTo(detailLabel.snp.bottom).offset(14 * scale)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(seedView)
        seedView.snp.makeConstraints { (make) in
            make.left.equalTo(descLabel.snp.left)
            make.centerX.equalToSuperview()
            make.top.equalTo(descLabel.snp.bottom).offset(26  * scale)
            make.height.equalTo(142)
        }
        
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints { (make) in
            make.left.equalTo(seedView.snp.left)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-bottomPadding)
            make.height.equalTo(48)
        }
        
        view.addSubview(warningView)
        warningView.snp.makeConstraints { (make) in
            make.left.equalTo(seedView.snp.left)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(doneButton.snp.top).offset(-24  * scale)
            make.height.equalTo(warningView.dynamicHeight)
        }
    }
}

/// MARK: event handle
extension TNVBackupsSeedController {
    
    @objc fileprivate func goBack() {
        for childViewController in (navigationController?.viewControllers)! {
            if childViewController.isKind(of: TNCreateAndRestoreWalletController.self) {
                navigationController?.popToViewController(childViewController, animated: true)
            }
        }
    }
    
    @objc fileprivate func backupCompleted() {
        
        alertAction(self, NSLocalizedString("Make sure have been backed up", comment: ""), message: nil, sureActionText: NSLocalizedString("Confirm", comment: ""), cancelActionText: NSLocalizedString("Cancel", comment: ""), isChange: true) {[weak self] in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                self?.navigationController?.pushViewController(TNVerifySeedViewController(), animated: true)
            }
        }
    }
}

extension TNVBackupsSeedController {
    
    fileprivate func generateRootPubkey() {
        TNEvaluateScriptManager.sharedInstance.generateRootPublicKey(xPrivKey: TNGlobalHelper.shared.xPrivKey)
    }
    
    fileprivate func generateMyDeviceAddress() {
        TNEvaluateScriptManager.sharedInstance.getMyDeviceAddress(xPrivKey: TNGlobalHelper.shared.xPrivKey)
    }
}
