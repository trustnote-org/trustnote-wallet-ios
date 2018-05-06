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
    let test = TNRestoreWalletViewModel()
    private let backgroungImageView = UIImageView().then {
        $0.image = UIImage(named: "bigBackground")
    }
    
    private let creatWalletBtn = UIButton().then {
        $0.backgroundColor = UIColor.white
        $0.setTitle(NSLocalizedString("Create Wallet", comment: ""), for: .normal)
        $0.setTitleColor(UIColor.hexColor(rgbValue: 0x009aff), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        $0.layer.cornerRadius = 20.0
        $0.layer.masksToBounds = true
    }
    
    private let restoreWalletBtn = UIButton().then {
        $0.backgroundColor = UIColor.clear
        $0.setTitle(NSLocalizedString("Restore Wallet", comment: ""), for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        $0.layer.cornerRadius = 20.0
        $0.layer.masksToBounds = true
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 1.0
    }
    
    fileprivate lazy var topView: TNCreateWalletTopView = {
        let topView = TNCreateWalletTopView.loadViewFromNib()
        return topView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        isSetStatusBar = true

        /// handle events
        creatWalletBtn.rx.tap.asObservable().subscribe(onNext: { [unowned self] _ in
            
            var isWait = false
            if TNGlobalHelper.shared.xPrivKey.isEmpty {
                isWait = true
                TNEvaluateScriptManager.sharedInstance.generateRootPrivateKeyByMnemonic(mnemonic: TNGlobalHelper.shared.mnemonic!)
            }
            let vc = TNCreateWalletController(titleText: NSLocalizedString("Create Wallet", comment: ""), wait: isWait)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }).disposed(by: self.disposeBag)
        
        restoreWalletBtn.rx.tap.asObservable().subscribe {[weak self] _ in
            self?.test.createNewWalletWhenRestoreWallet()
        }.disposed(by: self.disposeBag)
    }
}


extension TNCreateAndRestoreWalletController {
    
    fileprivate func setupUI() {
        view.addSubview(backgroungImageView)
        backgroungImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kStatusbarH)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kSafeAreaBottomH)
        }
        
        view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(80 + kStatusbarH)
            make.left.right.equalToSuperview()
            make.height.equalTo(150)
        }
        
        view.addSubview(creatWalletBtn)
        creatWalletBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(30)
            make.width.equalTo(160)
            make.height.equalTo(40)
        }
        
        view.addSubview(restoreWalletBtn)
        restoreWalletBtn.snp.makeConstraints { (make) in
            make.top.equalTo(creatWalletBtn.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(creatWalletBtn.snp.width)
            make.height.equalTo(creatWalletBtn.snp.height)
        }
    }
}

