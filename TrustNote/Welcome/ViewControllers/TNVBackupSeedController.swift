//
//  TNVBackupSeedController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/30.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNVBackupSeedController: TNNavigationController {
    
    fileprivate let flipDuration = 0.5
        
    fileprivate lazy var frontView: TNBackupSeedFrontView = {[weak self] in
        let frontView = TNBackupSeedFrontView.backupSeedFrontView()
        frontView.clickedNextBlock = {
            self?.switchFrontView()
        }
        return frontView
    }()
    
    fileprivate lazy var backView: TNBackupSeedBackView = {[weak self] in
        let backView = TNBackupSeedBackView.backupSeedBackView()
        backView.clickedLastStepBlock = {
            self?.switchBackView()
        }
        return backView
    }()
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor.hexColor(rgbValue: 0x222222, alpha: 0.9)
    }
    init(titleText: String) {
        super.init()
        self.navigationBar.titleText = titleText
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        view.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(kNavBarHeight, 0, kSafeAreaBottomH, 0))
        }
        
        containerView.addSubview(frontView)
        frontView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
       // createNewWallet()
    }
    
    func createNewWallet() {
        
        let walletViewModel = TNWalletViewModel()
        walletViewModel.generateNewWalletByDatabaseNumber {
            walletViewModel.saveNewWalletToProfile(TNGlobalHelper.shared.currentWallet)
            walletViewModel.saveWalletDataToDatabase(TNGlobalHelper.shared.currentWallet)
            if !TNGlobalHelper.shared.currentWallet.xPubKey.isEmpty {
                walletViewModel.generateWalletAddress(wallet_xPubKey: TNGlobalHelper.shared.currentWallet.xPubKey, change: false, num: 0, comletionHandle: { (walletAddressModel) in
                    walletViewModel.insertWalletAddressToDatabase(walletAddressModel: walletAddressModel)
                })
            }
        }
    }
}

extension TNVBackupSeedController {
    
    fileprivate func switchFrontView() {
        
        UIView.transition(with: frontView,
                      duration: flipDuration,
                       options: UIViewAnimationOptions.transitionFlipFromLeft,
                    animations: {() -> Void in},
                    completion: {(finished:Bool) -> Void in}
        )
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01, execute: {
            
            self.frontView.addSubview(self.backView)
            self.backView.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        })
    }
    
    fileprivate func switchBackView() {
        
        TNSQLiteManager.sharedManager.queryAmountFromOutputs(walletId: /*"RoW6sFKEumL5VW7HM9BFhfrMN9qeyFKCSlrjptxdgn8="*/"LyzbDDiDedJh+fUHMFAXpWSiIw/Z1Tgve0J1+KOfT3w=") { (results) in
            
            var balance: Int = 0
            for balanceModel in results as! [TNWalletBalance] {
                balance += Int(balanceModel.amount)!
            }
            let fBalance = Double(balance) / 1000000.0
            print(String(format: "%.5f", fBalance))
        }
       
        UIView.transition(with: frontView,
                          duration: flipDuration,
                          options: UIViewAnimationOptions.transitionFlipFromRight,
                          animations: {() -> Void in},
                          completion: {(finished:Bool) -> Void in
                             UIWindow.setWindowRootController(UIApplication.shared.keyWindow, rootVC: .main)
                          }
        )
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01, execute: {
            self.backView .removeFromSuperview()
        })
    }
}
