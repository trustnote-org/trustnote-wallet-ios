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
import SnapKit

 let maxInputCount = 20

class TNModifyDeviceNameController: TNBaseViewController {
    
    let topPadding = IS_iphone5 ? 70.0 : 90.0
    
    var lineHeightConstraint: Constraint?
    
    private let iconView = UIImageView().then {
        $0.backgroundColor = UIColor.clear
        $0.image = UIImage(named: "welcome_wallet")
    }
    
    private let textLabel = UILabel().then {
        $0.textColor = kTitleTextColor
        $0.font = kTitleFont
        $0.text = "Welocme To TrustNote".localized
    }
    
    private let instructionLabel = UILabel().then {
        $0.textColor = kThemeTextColor
        $0.font = UIFont(name: "PingFangSC-Light", size: 14)
        $0.numberOfLines = 0
        $0.text = "DeviceName.instruction".localized
    }
    
    private let deviceTextField = UITextField().then {
        $0.textColor = kThemeTextColor
        $0.font = UIFont(name: "PingFangSC-Medium", size: 18)
        $0.keyboardType = .asciiCapable
        $0.text = UIDevice.current.name
        $0.placeholder = "Please enter device name".localized
    }
    
    private let lineView = UIView().then {
        $0.backgroundColor = UIColor.hexColor(rgbValue: 0xdddddd)
        $0.height = 1.0
    }
    
    private let clearButton = UIButton().then {
        $0.setImage(UIImage(named: "welcome_clear"), for: .normal)
        $0.isHidden = true
    }
    
    private let warningImgView = UIImageView().then {
        $0.image = UIImage(named: "welcome_warning")
        $0.isHidden = true
    }
    
    private let warningLabel = UILabel().then {
        $0.text = "No more than 20 characters".localized
        $0.textColor = kWarningHintColor
        $0.font = UIFont.systemFont(ofSize: 14.0)
        $0.isHidden = true
    }
    
    private let confirmBtn = TNButton().then {
        $0.setBackgroundImage(UIImage.creatImageWithColor(color: kGlobalColor, viewSize: CGSize(width:  kScreenW, height: 48)), for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.setTitle("Confirm".localized, for: .normal)
        $0.titleLabel?.font = kButtonFont
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceTextField.delegate = self
        setupUI()
        
        let deviceObserver = deviceTextField.rx.text.orEmpty.asDriver().debounce(0.1).map {$0.count > 0}
        deviceObserver.drive(confirmBtn.rx_validState).disposed(by: self.disposeBag)
        deviceTextField.addTarget(self, action: #selector(self.textDidChanged), for: .editingChanged)
       
        confirmBtn.rx.tap.asObservable().subscribe(onNext: {[unowned self] _ in
            guard (self.deviceTextField.text?.count)! <= maxInputCount else {
                self.warningImgView.isHidden = false
                self.warningLabel.isHidden = false
                return
            }
            self.generateMnemonic()
        }).disposed(by: self.disposeBag)
        
        clearButton.rx.tap.asObservable().subscribe (onNext: {[unowned self] _ in
            self.deviceTextField.text = nil
            self.confirmBtn.isEnabled = false
            self.confirmBtn.alpha = 0.3
            self.clearButton.isHidden = true
        }).disposed(by: self.disposeBag)
    }
    
    func generateMnemonic() {
        
        let hud = MBProgress_TNExtension.showHUDAddedToView(view: self.view, title: "", animated: true)
        DispatchQueue.global().async {
            TNGlobalHelper.shared.mnemonic = TNSyncOperationManager.shared.getNewMnemonic()
            DispatchQueue.main.async {
                hud.removeFromSuperview()
                TNConfigFileManager.sharedInstance.updateConfigFile(key: "keywindowRoot", value: 3)
                TNConfigFileManager.sharedInstance.updateConfigFile(key: "deviceName", value: self.deviceTextField.text!)
                UIWindow.setWindowRootController(UIApplication.shared.keyWindow, rootVC: .newWallet)
            }
        }
    }
    
    @objc func textDidChanged(textField: UITextField) {
        clearButton.isHidden = (deviceTextField.text?.length)! > 0 ? false : true
    }
}


extension TNModifyDeviceNameController: UITextFieldDelegate {
   
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !warningImgView.isHidden {
            warningImgView.isHidden = true
            warningLabel.isHidden = true
        }
 
        lineView.snp.remakeConstraints { (make) -> Void in
            make.top.equalTo(deviceTextField.snp.bottom)
            make.left.equalTo(deviceTextField.snp.left)
            make.centerX.equalToSuperview()
            make.height.equalTo(2.0)
        }
        lineView.backgroundColor = kGlobalColor
        
        clearButton.isHidden = (deviceTextField.text?.length)! > 0 ? false : true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        lineView.snp.remakeConstraints { (make) -> Void in
            make.top.equalTo(deviceTextField.snp.bottom)
            make.left.equalTo(deviceTextField.snp.left)
            make.centerX.equalToSuperview()
            make.height.equalTo(1.0)
        }
        lineView.backgroundColor = kLineViewColor
        clearButton.isHidden = true
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
        
        view.addSubview(warningImgView)
        warningImgView.snp.makeConstraints { (make) in
            make.left.equalTo(deviceTextField.snp.left)
            make.top.equalTo(lineView.snp.bottom).offset(10)
        }
        
        view.addSubview(warningLabel)
        warningLabel.snp.makeConstraints { (make) in
            make.left.equalTo(warningImgView.snp.right).offset(6)
            make.centerY.equalTo(warningImgView.snp.centerY)
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

