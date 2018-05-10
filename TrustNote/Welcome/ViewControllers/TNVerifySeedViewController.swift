//
//  TNVerifySeedViewController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/9.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNVerifySeedViewController: TNBaseViewController {
    
    private let backBtn = UIButton().then {
        $0.setImage(UIImage(named: "welcome_back"), for: .normal)
        $0.addTarget(self, action: #selector(TNVerifySeedViewController.goBack), for: .touchUpInside)
    }
    
    private let titleTextLabel = UILabel().then {
        $0.text =  NSLocalizedString("Verifying notes", comment: "")
        $0.textColor = UIColor.hexColor(rgbValue: 0x111111)
        $0.font = UIFont.boldSystemFont(ofSize: 24.0)
    }
    
    private let descLabel = UILabel().then {
        $0.text =  NSLocalizedString("Verifying.description", comment: "")
        $0.textColor = kThemeTextColor
        $0.font = UIFont.systemFont(ofSize: 14.0)
        $0.numberOfLines = 0
    }
    
    private let doneButton = TNButton().then {
        $0.setBackgroundImage(UIImage.creatImageWithColor(color: kGlobalColor, viewSize: CGSize(width:  kScreenW, height: 48)), for: .normal)
        $0.setTitle(NSLocalizedString("Verification done", comment: ""), for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        $0.addTarget(self, action: #selector(TNVerifySeedViewController.verifyCompleted), for: .touchUpInside)
        $0.isEnabled = false
        $0.alpha = 0.3
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
    
    fileprivate lazy var seedView: TNBackupSeedBackView = {[weak self] in
        let seedView = TNBackupSeedBackView.backupSeedBackView()
        seedView.seedContainerView.isCanEdit = true
        return seedView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        layoutAllSubviews()
        seedView.seedContainerView.isVerifyButtonEnable.asDriver()
            .drive(doneButton.rx_validState)
            .disposed(by: self.disposeBag)
        
        seedView.seedContainerView.isBeingEdited.asObservable().subscribe(onNext: {[unowned self] value in
            guard !self.warningImageView.isHidden else {return}
            self.warningLabel.isHidden = true
            self.warningImageView.isHidden = true
        }).disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let firstResponder = seedView.seedContainerView.textFields.first
        firstResponder?.becomeFirstResponder()
    }
}

/// MARK: Subviews  Layout
extension TNVerifySeedViewController {
    
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
        
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints { (make) in
            make.left.equalTo(seedView.snp.left)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(26+kSafeAreaBottomH))
            make.height.equalTo(48)
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
    }
}

/// MARK: event handle
extension TNVerifySeedViewController {
    
    @objc fileprivate func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func verifyCompleted() {
        var seedPhrase = ""
        for (index, textField) in seedView.seedContainerView.textFields.enumerated() {
            seedPhrase.append(textField.text!)
            if index != seedView.seedContainerView.textFields.count - 1 {
                seedPhrase.append(" ")
            }
        }
        
        guard seedPhrase == TNGlobalHelper.shared.mnemonic else {
            warningImageView.isHidden = false
            warningLabel.isHidden = false
            return
        }
        if !warningImageView.isHidden {
            warningImageView.isHidden = true
            warningLabel.isHidden = true
        }
        TNConfigFileManager.sharedInstance.updateConfigFile(key: "keywindowRoot", value: 4)
        navigationController?.pushViewController(TNVerifyCompletionController(), animated: true)
    }
}
