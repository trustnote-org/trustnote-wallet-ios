//
//  TNModifyPasswordController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/1.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import RxSwift
import RxCocoa

class TNModifyPasswordController: TNNavigationController {
    
    let bottomPadding = IS_iPhoneX ? (kSafeAreaBottomH + 26) : CGFloat(26 * scale)
    
    fileprivate var isButtonValid: BehaviorRelay<Bool> =  BehaviorRelay(value: false)
    
    let titleLabel = UILabel().then {
        $0.textColor = kTitleTextColor
        $0.font = kTitleFont
        $0.text = "Profile.setupPassword".localized
    }
    
    private let confirmButton = TNButton().then {
        $0.setBackgroundImage(UIImage.creatImageWithColor(color: kGlobalColor, viewSize: CGSize(width:  kScreenW, height: 48)), for: .normal)
        $0.setTitle("Confirm".localized, for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.titleLabel?.font = kButtonFont
        $0.addTarget(self, action: #selector(TNModifyPasswordController.setupCompleted), for: .touchUpInside)
    }
    
    fileprivate lazy var warningView: TNBackupWarningView = {
        let warningView = TNBackupWarningView.backupWarningView()
        warningView.setupRadiusCorner(radius: kCornerRadius)
        warningView.tips = ["Password.firstWarning".localized, "Password.secondWarning".localized]
        return warningView
    }()
    
    fileprivate lazy var passwordView: TNProfileSetupPasswordView = {
        let passwordView = TNProfileSetupPasswordView.profileSetupPasswordView()
        return passwordView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        layoutAllSubviews()
        passwordView.delegate = self
        isButtonValid.asDriver().drive(confirmButton.rx_validState).disposed(by: self.disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        if passwordView.confirmTextField.isFirstResponder {
            passwordView.confirmTextField.resignFirstResponder()
            view.y = 0
        }
    }
}

extension TNModifyPasswordController {
    
    @objc fileprivate func setupCompleted() {
        passwordView.passwordSecurityView.isHidden = true
        
        guard (passwordView.newTextField.text?.length)! >= textValidCount else {
            passwordView.passwdRuleLabel.isHidden = false
            passwordView.passwordRuleImgView.isHidden = false
            passwordView.passwdRuleLabel.textColor = kWarningHintColor
            passwordView.ruleLabelLeftMargin.constant = 20
            return
        }
        guard passwordView.newTextField.text == passwordView.confirmTextField.text else {
            passwordView.errorView.isHidden = false
            return
        }
        let md5Str = passwordView.originTextField.text?.md5()
        guard md5Str == Preferences[.encryptionPassword] else {
            alertAction(self, "Original password input error".localized, message: nil, sureActionText: nil, cancelActionText: "Confirm".localized, isChange: false, sureAction: nil)
            return
        }
        Preferences[.encryptionPassword] = passwordView.newTextField.text?.md5()
        let xPrivkey = AES128CBC_Unit.aes128Decrypt(TNGlobalHelper.shared.encryptePrivKey, key: passwordView.originTextField.text)
        let encPrivKey = AES128CBC_Unit.aes128Encrypt(xPrivkey, key: passwordView.newTextField.text)
        TNGlobalHelper.shared.encryptePrivKey = encPrivKey!
        TNConfigFileManager.sharedInstance.updateProfile(key: "xPrivKey", value: encPrivKey!)
        MBProgress_TNExtension.showViewAfterSecond(title: "密码设置成功")
        navigationController?.popViewController(animated: true)
    }
}

extension TNModifyPasswordController: TNProfileSetupPasswordViewDelegate {
    
    func inputDidChanged(_ isValid: Bool) {
        isButtonValid.accept(isValid)
    }
}

extension TNModifyPasswordController {
    
    fileprivate func layoutAllSubviews() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom).offset(9)
            make.left.equalToSuperview().offset(kLeftMargin)
        }
        
        view.addSubview(warningView)
        warningView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.left)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(24 * scale)
            make.height.equalTo(warningView.dynamicHeight)
        }
        
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.left)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-bottomPadding)
            make.height.equalTo(48)
        }
        
        let verticalMaigin = IS_iphone5 ? 5 : 30
        view.addSubview(passwordView)
        passwordView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kLeftMargin)
            make.right.equalToSuperview().offset(-kLeftMargin)
            make.top.equalTo(warningView.snp.bottom).offset(verticalMaigin)
            make.bottom.equalTo(confirmButton.snp.top).offset(-verticalMaigin)
        }
    }
    
}
