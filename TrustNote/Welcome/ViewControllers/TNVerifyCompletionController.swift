//
//  TNVerifyCompletionController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/9.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNVerifyCompletionController: TNBaseViewController {
    
    let topPadding = IS_iphone5 ? 70.0 : 90.0
    let bottomPadding = IS_iPhoneX ? (kSafeAreaBottomH + 26) : 26
    
    private let iconView = UIImageView().then {
        $0.backgroundColor = UIColor.clear
        $0.image = UIImage(named: "welcome_verify")
    }
    
    private let textLabel = UILabel().then {
        $0.textColor = kTitleTextColor
        $0.font = kTitleFont
        $0.text = NSLocalizedString("Verifying words correct", comment: "")
    }
    
    private let instructionLabel = UILabel().then {
        $0.textColor = kThemeTextColor
        $0.font = UIFont.systemFont(ofSize: 14.0)
        $0.numberOfLines = 0
        $0.text = NSLocalizedString("VerifyingCompletion.instruction", comment: "")
    }
    
    private let deleteBtn = TNButton().then {
        $0.setBackgroundImage(UIImage.creatImageWithColor(color: kGlobalColor, viewSize: CGSize(width:  kScreenW, height: 48)), for: .normal)
        $0.setTitle(NSLocalizedString("Delete words", comment: ""), for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.titleLabel?.font = kButtonFont
    }
    
    private let skipBtn = TNButton().then {
        $0.backgroundColor = UIColor.white
        $0.setTitle(NSLocalizedString("Skip", comment: ""), for: .normal)
        $0.setTitleColor(kGlobalColor, for: .normal)
        $0.titleLabel?.font = kButtonFont
        $0.layer.borderColor = kGlobalColor.cgColor
        $0.layer.borderWidth = 1.0
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        layoutAllSubviews()
        TNGlobalHelper.shared.mnemonic = ""
        TNGlobalHelper.shared.password = nil
        TNGlobalHelper.shared.isNeedLoadData = false
        deleteBtn.rx.tap.asObservable().subscribe(onNext: {[unowned self] _ in
            self.deleteSeedPhrase()
        }).disposed(by: self.disposeBag)
        
        skipBtn.rx.tap.asObservable().subscribe(onNext: { _ in
            TNGlobalHelper.shared.isVerifyPasswdForMain = false
            UIWindow.setWindowRootController(UIApplication.shared.keyWindow, rootVC: .main)
        }).disposed(by: self.disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated:Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

extension TNVerifyCompletionController {
    
    fileprivate func layoutAllSubviews() {
        
        view.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topPadding)
            make.left.equalToSuperview().offset(kLeftMargin)
            make.width.height.equalTo(67)
        }
        
        view.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconView.snp.bottom).offset(48)
            make.left.equalTo(iconView.snp.left)
        }
        
        view.addSubview(instructionLabel)
        instructionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textLabel.snp.bottom).offset(16)
            make.left.equalTo(iconView.snp.left)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(skipBtn)
        skipBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-bottomPadding)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(26)
            make.height.equalTo(48)
        }
        
        view.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.left.equalTo(skipBtn.snp.left)
            make.bottom.equalTo(skipBtn.snp.top).offset(-24)
            make.height.equalTo(skipBtn.snp.height)
        }
    }
}

extension TNVerifyCompletionController {
    
    fileprivate func deleteSeedPhrase() {
        alertAction(self, NSLocalizedString("Make sure delete words", comment: ""), message: nil, sureActionText: NSLocalizedString("Confirm", comment: ""), cancelActionText: NSLocalizedString("Cancel", comment: ""), isChange: true) {
            TNGlobalHelper.shared.isVerifyPasswdForMain = false
            TNConfigFileManager.sharedInstance.updateProfile(key: "mnemonic", value: "")
            UIWindow.setWindowRootController(UIApplication.shared.keyWindow, rootVC: .main)
        }
    }
}
