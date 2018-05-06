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

class TNModifyDeviceNameController: TNNavigationController {
    
    private let iconView = UIImageView().then {
        $0.backgroundColor = UIColor.clear
        $0.image = UIImage(named: "timg")
    }
    
    private let textLabel = UILabel().then {
        $0.textColor = UIColor.hexColor(rgbValue: 0x222222)
        $0.font = UIFont.boldSystemFont(ofSize: 18.0)
        $0.textAlignment = .center
        $0.text = NSLocalizedString("Welocme To TrustNote", comment: "")
    }
    
    private let instructionLabel = UILabel().then {
        $0.textColor = UIColor.hexColor(rgbValue: 0x666666)
        $0.font = UIFont.boldSystemFont(ofSize: 14.0)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = NSLocalizedString("DeviceName.instruction", comment: "")
    }
    
    private let deviceTextField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.textColor = UIColor.hexColor(rgbValue: 0x444444)
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 16.0)
        $0.keyboardType = .asciiCapable
        $0.text = UIDevice.current.model
    }
    
    private let nextBtn = UIButton().then {
        $0.backgroundColor = UIColor.hexColor(rgbValue: 0x11aaff)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        $0.layer.cornerRadius = 20.0
        $0.layer.masksToBounds = true
        $0.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        isSetStatusBar = false
        navigationBar.titleText = "TrustNote"
        setupUI()
       
        let deviceObserverable = deviceTextField.rx.text.orEmpty.asDriver()
            .debounce(0.3)
            .map {$0.count > 0}
        
        deviceObserverable.drive(nextBtn.rx_validState).disposed(by: self.disposeBag)
        
        nextBtn.rx.tap.asObservable().subscribe(onNext: { _ in
            
            TNConfigFileManager.sharedInstance.updateConfigFile(key: "keywindowRoot", value: 3)
            UIWindow.setWindowRootController(UIApplication.shared.keyWindow, rootVC: .newWallet)
            
        }).disposed(by: self.disposeBag)
    }
    
}

extension TNModifyDeviceNameController {
    
    fileprivate func setupUI() {
    
        view.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom).offset(70)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(70)
        }
        
        view.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconView.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(instructionLabel)
        instructionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(deviceTextField)
        deviceTextField.snp.makeConstraints { (make) in
            make.top.equalTo(instructionLabel.snp.bottom).offset(20)
            make.left.equalTo(instructionLabel.snp.left)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
        
        view.addSubview(nextBtn)
        nextBtn.snp.makeConstraints { (make) in
            make.top.equalTo(deviceTextField.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
    }
}

extension UIButton {
    var rx_validState: AnyObserver<Bool> {
        return Binder(self) { button, valid in
            button.isEnabled = valid
            button.backgroundColor = valid ? UIColor.hexColor(rgbValue: 0x33aaff) : UIColor.lightGray
            }.asObserver()
    }
}

