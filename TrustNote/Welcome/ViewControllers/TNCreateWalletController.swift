//
//  TNCreateWalletController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/28.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit


class TNCreateWalletController: TNNavigationController {
    
    var waitUnitGeneratePrivkey = false
    
    private let iconView = UIImageView().then {
        $0.backgroundColor = UIColor.clear
        $0.image = UIImage(named: "create_wallet_tag_image")
    }
    
    private let textLabel = UILabel().then {
        $0.textColor = UIColor.hexColor(rgbValue: 0x222222)
        $0.font = UIFont.boldSystemFont(ofSize: 17.0)
        $0.textAlignment = .center
        $0.text = NSLocalizedString("Create Wallet and Backup Your Seed Phrase", comment: "")
    }
    
    private let instructionLabel = UILabel().then {
        $0.textColor = UIColor.hexColor(rgbValue: 0x666666)
        $0.font = UIFont.boldSystemFont(ofSize: 14.0)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = NSLocalizedString("CreateWallet.instruction", comment: "")
    }
    
    private let nextBtn = UIButton().then {
        $0.backgroundColor = UIColor.hexColor(rgbValue: 0x11aaff)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        $0.layer.cornerRadius = 20.0
        $0.layer.masksToBounds = true
    }
    
    // MARK: Initializing
    init(titleText: String, wait: Bool) {
        super.init()
        self.navigationBar.titleText = titleText
        self.waitUnitGeneratePrivkey = wait
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setupSubViews()
        
        if TNGlobalHelper.shared.my_device_address.isEmpty && !waitUnitGeneratePrivkey {
            generateMyDeviceAddress()
        }
        if TNGlobalHelper.shared.xPubkey.isEmpty && !waitUnitGeneratePrivkey {
            generateRootPubkey()
        }
        
        nextBtn.rx.tap.asObservable().subscribe(onNext: { [unowned self] _ in
            
            let vc = TNVBackupSeedController(titleText: NSLocalizedString("Backup Your Seed Phrase", comment: ""))
            self.navigationController?.pushViewController(vc, animated: true)
            
        }).disposed(by: self.disposeBag)
        
        let notificationName = Notification.Name(rawValue: TNDidGeneratedPrivateKey)
        _ = NotificationCenter.default.rx.notification(notificationName).takeUntil(self.rx.deallocated).subscribe(onNext: { [unowned self] _ in
            if TNGlobalHelper.shared.xPubkey.isEmpty {
                self.generateRootPubkey()
            }
            if TNGlobalHelper.shared.my_device_address.isEmpty {
                 self.generateMyDeviceAddress()
            }
        })
    }   
}

extension TNCreateWalletController {
    
    fileprivate func setupSubViews() {
        
        view.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom).offset(70)
            make.centerX.equalToSuperview()
            make.width.equalTo(87)
            make.height.equalTo(76)
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
        
        view.addSubview(nextBtn)
        nextBtn.snp.makeConstraints { (make) in
            make.top.equalTo(instructionLabel.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
    }
}
/// MARK: Notification
extension TNCreateWalletController {
    
    fileprivate func generateRootPubkey() {
        TNEvaluateScriptManager.sharedInstance.generateRootPublicKey(xPrivKey: TNGlobalHelper.shared.xPrivKey)
    }
    
    fileprivate func generateMyDeviceAddress() {
        TNEvaluateScriptManager.sharedInstance.getMyDeviceAddress(xPrivKey: TNGlobalHelper.shared.xPrivKey)
    }
}

