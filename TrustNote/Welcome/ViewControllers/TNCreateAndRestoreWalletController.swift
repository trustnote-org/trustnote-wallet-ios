//
//  TNCreateAndRestoreWalletController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/29.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift


class TNCreateAndRestoreWalletController: TNBaseViewController {
   
    let bottomPadding = IS_iPhoneX ? (kSafeAreaBottomH + 64) : 64
    let topPadding = IS_iphone5 ? (88 + kStatusbarH) : (128 + kStatusbarH)
   
    private let creatWalletBtn = TNButton().then {
        $0.setBackgroundImage(UIImage.creatImageWithColor(color: kGlobalColor, viewSize: CGSize(width:  kScreenW, height: 48)), for: .normal)
        $0.setTitle("Create wallet".localized, for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
    }
    
    private let restoreWalletBtn = TNButton().then {
        $0.backgroundColor = UIColor.white
        $0.setTitle("Restore wallet".localized, for: .normal)
        $0.setTitleColor(kGlobalColor, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        $0.layer.borderColor = kGlobalColor.cgColor
        $0.layer.borderWidth = 1.0
    }
    
    fileprivate lazy var topView: TNCreateWalletTopView = {
        let topView = TNCreateWalletTopView.loadViewFromNib()
        return topView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        /// handle events
        creatWalletBtn.rx.tap.asObservable().subscribe(onNext: { [unowned self] _ in
            
            if TNGlobalHelper.shared.encryptePrivKey.isEmpty {
                TNEvaluateScriptManager.sharedInstance.generateRootPrivateKeyByMnemonic(mnemonic: TNGlobalHelper.shared.mnemonic) { (xPrivkey) in
                    TNGlobalHelper.shared.tempPrivKey = xPrivkey
                    if let passsword = TNGlobalHelper.shared.password {
                        let encPrivKey = AES128CBC_Unit.aes128Encrypt(xPrivkey, key: passsword)
                        TNGlobalHelper.shared.encryptePrivKey = encPrivKey!
                        TNConfigFileManager.sharedInstance.updateProfile(key: "xPrivKey", value: encPrivKey!)
                    }
                    TNEvaluateScriptManager.sharedInstance.getEcdsaPrivkey(xPrivKey: xPrivkey) {
                        TNHubViewModel.loginHub()
                    }
                }
            }
            self.isEnterSetupPassword(vc: TNVBackupsSeedController())
            
        }).disposed(by: self.disposeBag)
        
        restoreWalletBtn.rx.tap.asObservable().subscribe {[weak self] _ in
            self?.isEnterSetupPassword(vc: TNRecoveryWalletController())
        }.disposed(by: self.disposeBag)
        
        if Preferences[.isBackupWords] {
            let vc = TNVerifyPasswordController()
            vc.verifyPasswordCompletionBlock = {[unowned self] in
                if Preferences[.isRecoverWallet] == 2 {
                    TNConfigFileManager.sharedInstance.updateProfile(key: "credentials", value: [])
                    TNSQLiteManager.sharedManager.deleteAllLocalData()
                    self.alertAction(self, "The last time the wallet was not completed, please ensure that the network is open and restored".localized, message: nil, sureActionText: nil, cancelActionText: "Confirm".localized, isChange: false, sureAction: nil)
                }
            }
            self.present(vc, animated: false) {
                vc.passwordAlertView.passwordTextField.becomeFirstResponder()
            }
        }
    }
    
}

extension TNCreateAndRestoreWalletController {
    
    fileprivate func setupUI() {
       
        view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topPadding)
            make.left.right.equalToSuperview()
            make.height.equalTo(190)
        }
        
        view.addSubview(restoreWalletBtn)
        restoreWalletBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-bottomPadding)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(26)
            make.height.equalTo(48)
        }
        
        view.addSubview(creatWalletBtn)
        creatWalletBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.left.equalTo(restoreWalletBtn.snp.left)
            make.bottom.equalTo(restoreWalletBtn.snp.top).offset(-24)
            make.height.equalTo(restoreWalletBtn.snp.height)
        }
    }
}

extension TNCreateAndRestoreWalletController {
    fileprivate func isEnterSetupPassword(vc: UIViewController) {
        var targetVC: UIViewController? = nil
        let encryptionPassword = Preferences[.encryptionPassword]
        if encryptionPassword?.count != 0 {
            targetVC = vc
        } else {
            let setupVC = TNSetupPasswordController(nibName: "\(TNSetupPasswordController.self)", bundle: nil)
            setupVC.isCreateWallet = vc.isKind(of: TNVBackupsSeedController.self) ? true : false
            targetVC = setupVC
        }
        self.navigationController?.pushViewController(targetVC!, animated: true)
    }
}

