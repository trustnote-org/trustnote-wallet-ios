//
//  TNModifyDeviceNameController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/28.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

 let maxInputCount = 21

class TNModifyDeviceNameController: TNBaseViewController {
    
    let topPadding = IS_iphone5 ? 70.0 : 90.0
    
    
    private let iconView = UIImageView().then {
        $0.backgroundColor = UIColor.clear
        $0.image = UIImage(named: "welcome_wallet")
    }
    
    private let textLabel = UILabel().then {
        $0.textColor = kTitleTextColor
        $0.font = kTitleFont
        $0.text = NSLocalizedString("Welocme To TrustNote", comment: "")
    }
    
    private let instructionLabel = UILabel().then {
        $0.textColor = kThemeTextColor
        $0.font = UIFont.systemFont(ofSize: 14.0)
        $0.numberOfLines = 0
        $0.text = NSLocalizedString("DeviceName.instruction", comment: "")
    }
    
    private let deviceTextField = UITextField().then {
        $0.textColor = kThemeTextColor
        $0.font = UIFont(name: "PingFangSC-Medium", size: 18)
        $0.keyboardType = .asciiCapable
        $0.text = UIDevice.current.name
        $0.placeholder = NSLocalizedString(
            "Please enter device name", comment: "")
    }
    
    private let lineView = UIView().then {
        $0.backgroundColor = UIColor.hexColor(rgbValue: 0xdddddd)
    }
    
    private let clearButton = UIButton().then {
        $0.setImage(UIImage(named: "welcome_clear"), for: .normal)
        $0.isHidden = false
    }
    
    private let warningBtn = TNButton().then {
        $0.setImage(UIImage(named: "welcome_warning"), for: .normal)
        $0.setTitle(NSLocalizedString("DeviceName.warning", comment: ""), for: .normal)
        $0.setTitleColor(UIColor.hexColor(rgbValue: 0xEF2B2B), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        $0.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        $0.isHidden = true
    }
    
    private let confirmBtn = TNButton().then {
        $0.setBackgroundImage(UIImage.creatImageWithColor(color: kGlobalColor, viewSize: CGSize(width:  kScreenW, height: 48)), for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.setTitle(NSLocalizedString("Confirm", comment: ""), for: .normal)
        $0.titleLabel?.font = kButtonFont
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceTextField.delegate = self
        setupUI()
        
        let deviceObserver = deviceTextField.rx.text.orEmpty.asDriver().debounce(0.1).map {$0.count > 0}
        deviceObserver.drive(confirmBtn.rx_validState).disposed(by: self.disposeBag)
        deviceObserver.drive(clearButton.rx_HiddenState).disposed(by: self.disposeBag)
       
        confirmBtn.rx.tap.asObservable().subscribe(onNext: {[unowned self] _ in
            guard (self.deviceTextField.text?.count)! < maxInputCount else {
                self.lineView.height = 2.0
                self.lineView.backgroundColor = kGlobalColor
                self.warningBtn.isHidden = false
                return
            }
            TNConfigFileManager.sharedInstance.updateConfigFile(key: "keywindowRoot", value: 3)
            TNConfigFileManager.sharedInstance.updateConfigFile(key: "deviceName", value: self.deviceTextField.text!)
            UIWindow.setWindowRootController(UIApplication.shared.keyWindow, rootVC: .newWallet)
        }).disposed(by: self.disposeBag)
        
        clearButton.rx.tap.asObservable().subscribe (onNext: {[unowned self] _ in
            self.deviceTextField.text = nil
            self.confirmBtn.isEnabled = false
            self.confirmBtn.alpha = 0.3
            self.warningBtn.isHidden = true
            self.clearButton.isHidden = true
            self.lineView.backgroundColor = UIColor.hexColor(rgbValue: 0xdddddd)
            self.lineView.height = 1.0
        }).disposed(by: self.disposeBag)
    }
    
}

extension TNModifyDeviceNameController {
    
    fileprivate func setupUI() {
        
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
        
        view.addSubview(deviceTextField)
        deviceTextField.snp.makeConstraints { (make) in
            make.top.equalTo(instructionLabel.snp.bottom).offset(45)
            make.left.equalTo(iconView.snp.left)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
        
        view.addSubview(clearButton)
        clearButton.snp.makeConstraints { (make) in
            make.right.equalTo(deviceTextField.snp.right).offset(12.0)
            make.centerY.equalTo(deviceTextField.snp.centerY)
            make.width.height.equalTo(44)
        }
        view.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(deviceTextField.snp.bottom)
            make.left.equalTo(deviceTextField.snp.left)
            make.centerX.equalToSuperview()
            make.height.equalTo(1.0)
        }
        
        view.addSubview(warningBtn)
        warningBtn.snp.makeConstraints { (make) in
            make.left.equalTo(deviceTextField.snp.left)
            make.top.equalTo(lineView.snp.bottom).offset(10)
            make.width.equalTo(125)
        }
        
        view.addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-64)
            make.centerX.equalToSuperview()
            make.left.equalTo(deviceTextField.snp.left)
            make.height.equalTo(48)
        }
    }
}


extension TNModifyDeviceNameController: UITextFieldDelegate {
   
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !warningBtn.isHidden {
            warningBtn.isHidden = true
            lineView.height = 1.0
            lineView.backgroundColor = kLineViewColor
        }
    }
}

