//
//  TNRecoveryWalletController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/13.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNRecoveryWalletController: TNBaseViewController {
    
    let bottomPadding = IS_iPhoneX ? (kSafeAreaBottomH + 26) : 26
    private var seedPhrase = ""
    let viewModel = TNRestoreWalletViewModel()
    var hub: String?
    var isDeleteMnemonic: Bool?
    var syncLoadingView : TNCustomAlertView?
    
    private let backBtn = UIButton().then {
        $0.setImage(UIImage(named: "welcome_back"), for: .normal)
        $0.addTarget(self, action: #selector(TNRecoveryWalletController.goBack), for: .touchUpInside)
    }
    
    private let titleTextLabel = UILabel().then {
        $0.text =  NSLocalizedString("Recover wallet", comment: "")
        $0.textColor = kTitleTextColor
        $0.font = UIFont.boldSystemFont(ofSize: 24.0)
    }
    
    private let descLabel = UILabel().then {
        $0.text =  NSLocalizedString("Wallet mnemonic", comment: "")
        $0.textColor = UIColor.hexColor(rgbValue: 0x666666)
        $0.font = UIFont.systemFont(ofSize: 14.0)
    }
    
    private let warningImageView = UIImageView().then {
        $0.image = UIImage(named: "welcome_warning")
        $0.isHidden = true
    }
    
    private let warningLabel = UILabel().then {
        $0.text = NSLocalizedString("Verification error", comment: "")
        $0.textColor = UIColor.hexColor(rgbValue: 0xEF2B2B)
        $0.font = UIFont.systemFont(ofSize: 12.0)
        $0.numberOfLines = 2
        $0.isHidden = true
    }
    
    private let recoverBtn = TNButton().then {
        $0.setBackgroundImage(UIImage.creatImageWithColor(color: kGlobalColor, viewSize: CGSize(width:  kScreenW, height: 48)), for: .normal)
        $0.setTitle(NSLocalizedString("Use the phrase to restore the wallet", comment: ""), for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        $0.isEnabled = false
        $0.alpha = 0.3
    }
    
    private let deleteBtn = TNButton().then {
        $0.backgroundColor = UIColor.white
        $0.setTitle(NSLocalizedString("Restore the wallet and delete the phrase", comment: ""), for: .normal)
        $0.setTitleColor(kGlobalColor, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        $0.layer.borderColor = kGlobalColor.cgColor
        $0.layer.borderWidth = 1.0
        $0.isEnabled = false
        $0.alpha = 0.3
    }
    
    
    fileprivate lazy var loadingView: TNSyncClonedWalletsView = {
        let loadingView = TNSyncClonedWalletsView.loadViewFromNib()
        loadingView.loadingText.text = "SyncLoading".localized
        return loadingView
    }()
    
    fileprivate lazy var seedView: TNBackupSeedBackView = {[weak self] in
        let seedView = TNBackupSeedBackView.backupSeedBackView()
        seedView.seedContainerView.isCanEdit = true
        return seedView
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutAllSubviews()
        seedView.seedContainerView.isVerifyButtonEnable.asDriver()
            .drive(recoverBtn.rx_validState)
            .disposed(by: self.disposeBag)
        seedView.seedContainerView.isVerifyButtonEnable.asDriver()
            .drive(deleteBtn.rx_validState)
            .disposed(by: self.disposeBag)
        
        seedView.seedContainerView.isBeingEdited.asObservable().subscribe(onNext: {[unowned self] value in
            guard !self.warningImageView.isHidden else {return}
            self.warningLabel.isHidden = true
            self.warningImageView.isHidden = true
        }).disposed(by: disposeBag)
        
        recoverBtn.rx.tap.asObservable().subscribe(onNext: {[unowned self] value in
            self.validationInput(isDelete: false)
        }).disposed(by: disposeBag)
        
        deleteBtn.rx.tap.asObservable().subscribe(onNext: {[unowned self] value in
            self.validationInput(isDelete: true)
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNDidGeneratedPrivateKeyNotification)).subscribe(onNext: {[unowned self] value in
            let result: String = value.object as! String
            guard  result == "0" else {
                self.finishGeneratePrivateKey()
                return
            }
            self.warningImageView.isHidden = false
            self.warningLabel.isHidden = false
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNDidFinishRecoverWalletNotification), object: nil).subscribe(onNext: {[unowned self] _ in
            guard TNGlobalHelper.shared.recoverStyle == .all && self.viewModel.isRecoverWallet else {
                return
            }
            self.finishRecoverWallet()
        }).disposed(by: disposeBag)
        
       seedView.seedContainerView.mnmnemonicsArr = TNGlobalHelper.shared.mnemonic.components(separatedBy: " ")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if navigationController?.viewControllers.count == 3 {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        super.viewDidAppear(animated)
        let firstResponder = seedView.seedContainerView.textFields.first
        firstResponder?.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated:Bool) {
        super.viewDidDisappear(animated)
        if navigationController?.viewControllers.count == 3 {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
}

/// MARK: event handle
extension TNRecoveryWalletController {
    
    @objc fileprivate func goBack() {
        view.endEditing(true)
        for childViewController in (navigationController?.viewControllers)! {
            if childViewController.isKind(of: TNCreateAndRestoreWalletController.self) {
                navigationController?.popToViewController(childViewController, animated: true)
            }
        }
    }
    
    fileprivate func validationInput(isDelete: Bool) {
        isDeleteMnemonic = isDelete
        loadingView.startAnimation()
        let popX = CGFloat(kLeftMargin)
        let popH: CGFloat = 190
        let popY = (kScreenH - popH) / 2
        let popW = kScreenW - popX * 2
        syncLoadingView = TNCustomAlertView(alert: loadingView, alertFrame: CGRect(x: popX, y: popY, width: popW, height: popH), AnimatedType: .none)
        var flag = true
        for (index, textField) in seedView.seedContainerView.textFields.enumerated() {
            if !seedView.seedContainerView.allWords.contains(textField.text!) {
                flag = false
                break
            }
            seedPhrase.append(textField.text!)
            if index != seedView.seedContainerView.textFields.count - 1 {
                seedPhrase.append(" ")
            }
        }
        guard flag else {
            loadingView.stopAnimation()
            syncLoadingView?.removeFromSuperview()
            warningImageView.isHidden = false
            warningLabel.isHidden = false
            return
        }
        TNGlobalHelper.shared.mnemonic = seedPhrase
        hub = TNWebSocketManager.sharedInstance.generateHUbAddress(isSave: false)
        TNWebSocketManager.sharedInstance.webSocketOpen(hubAddress: hub!)
        TNWebSocketManager.sharedInstance.generateNewPrivkeyBlock = {
            self.createPrivateKey()
        }
    }
    
    fileprivate func createPrivateKey() {
        
        TNEvaluateScriptManager.sharedInstance.generateRootPrivateKeyByMnemonic(mnemonic: seedPhrase)
    }
    
    fileprivate func finishGeneratePrivateKey() {
        
        TNConfigFileManager.sharedInstance.updateProfile(key: "credentials", value: [])
        TNEvaluateScriptManager.sharedInstance.getMyDeviceAddress(xPrivKey: TNGlobalHelper.shared.xPrivKey)
        TNGlobalHelper.shared.tempPrivKey = ""
        TNSQLiteManager.sharedManager.deleteAllWallets()
        viewModel.isRecoverWallet = true
        TNGlobalHelper.shared.recoverStyle = .all
        viewModel.createNewWalletWhenRestoreWallet()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    fileprivate func finishRecoverWallet() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        viewModel.isRecoverWallet = false
        TNGlobalHelper.shared.recoverStyle = .none
        TNConfigFileManager.sharedInstance.updateConfigFile(key: "hub", value: hub!)
        TNEvaluateScriptManager.sharedInstance.generateRootPublicKey(xPrivKey: TNGlobalHelper.shared.xPrivKey)
        
        if isDeleteMnemonic! {
            TNConfigFileManager.sharedInstance.updateProfile(key: "mnemonic", value: "")
        } else {
            TNConfigFileManager.sharedInstance.updateProfile(key: "mnemonic", value: TNGlobalHelper.shared.mnemonic)
        }
        TNGlobalHelper.shared.mnemonic = ""
        TNGlobalHelper.shared.password = nil
        TNGlobalHelper.shared.isVerifyPasswdForMain = false
        TNGlobalHelper.shared.isNeedLoadData = false
        TNConfigFileManager.sharedInstance.updateConfigFile(key: "keywindowRoot", value: 4)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.loadingView.stopAnimation()
            self.syncLoadingView?.removeFromSuperview()
            UIWindow.setWindowRootController(UIApplication.shared.keyWindow, rootVC: .main)
        }
    }
}

extension TNRecoveryWalletController {
    
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
            make.top.equalTo(backBtn.snp.bottom).offset(9)
        }
        
        view.addSubview(descLabel)
        descLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleTextLabel.snp.left)
            make.top.equalTo(titleTextLabel.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(seedView)
        seedView.snp.makeConstraints { (make) in
            make.left.equalTo(descLabel.snp.left)
            make.centerX.equalToSuperview()
            make.top.equalTo(descLabel.snp.bottom).offset(26)
            make.height.equalTo(284)
        }
        
        view.addSubview(warningImageView)
        warningImageView.snp.makeConstraints { (make) in
            make.left.equalTo(descLabel.snp.left)
            make.top.equalTo(seedView.snp.top).offset(154)
        }
        
        view.addSubview(warningLabel)
        warningLabel.snp.makeConstraints { (make) in
            make.left.equalTo(warningImageView.snp.right).offset(6)
            make.top.equalTo(warningImageView.snp.top)
            make.right.equalTo(seedView.snp.right)
        }
        
        view.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-bottomPadding)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(26)
            make.height.equalTo(48)
        }
        
        view.addSubview(recoverBtn)
        recoverBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.left.equalTo(deleteBtn.snp.left)
            make.bottom.equalTo(deleteBtn.snp.top).offset(-24)
            make.height.equalTo(deleteBtn.snp.height)
        }
    }
}
