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
    
    let bottomPadding = IS_iPhoneX ? (kSafeAreaBottomH + 80) : 80
    let topPadding = IS_iphone5 ? (88 + kStatusbarH) : (128 + kStatusbarH)
    let test = TNRestoreWalletViewModel()
   
    private let creatWalletBtn = TNButton().then {
        $0.setBackgroundImage(UIImage.creatImageWithColor(color: kGlobalColor, viewSize: CGSize(width:  kScreenW, height: 48)), for: .normal)
        $0.setTitle(NSLocalizedString("Create Wallet", comment: ""), for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
    }
    
    private let restoreWalletBtn = TNButton().then {
        $0.backgroundColor = UIColor.white
        $0.setTitle(NSLocalizedString("Restore Wallet", comment: ""), for: .normal)
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
            
            var isWait = false
            if TNGlobalHelper.shared.xPrivKey.isEmpty {
                isWait = true
                TNEvaluateScriptManager.sharedInstance.generateRootPrivateKeyByMnemonic(mnemonic: TNGlobalHelper.shared.mnemonic!)
            }
            var targetVC: UIViewController? = nil
            let encryptionPassword = Preferences[.encryptionPassword]
            if encryptionPassword?.count != 0 {
                targetVC = TNVBackupsSeedController()
            } else {
                targetVC = TNSetupPasswordController(nibName: "\(TNSetupPasswordController.self)", bundle: nil)
            }
            self.navigationController?.pushViewController(targetVC!, animated: true)
            
        }).disposed(by: self.disposeBag)
        
        restoreWalletBtn.rx.tap.asObservable().subscribe {[weak self] _ in
            self?.test.createNewWalletWhenRestoreWallet()
        }.disposed(by: self.disposeBag)
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

