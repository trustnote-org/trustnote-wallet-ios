//
//  TNRecoverObserveWallet.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/22.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import RxSwift

class TNRecoverObserveWallet {
    
    let disposeBag = DisposeBag()
    private let walletViewModel = TNWalletViewModel()
    public var isRecoverWallet = true
    private var isGenerateFrontAddress = true
    private var addressIndex = 0
    private var isChange = false
    private var currentWallet: TNWalletModel?
    private var addressModels: [TNWalletAddressModel] = []
    private var tempAddressModels: [TNWalletAddressModel] = []
    required init() {
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNDidReceiveRestoreWalletResponse), object: nil).subscribe(onNext: {[unowned self] (notify) in
            guard self.isRecoverWallet else {return}
            let response = notify.object as! [String : Any]
            guard response.isEmpty else {
                self.tempAddressModels.removeAll()
                self.createWalletAddress(num: self.addressIndex)
                return
            }
            if !self.isChange {
                guard self.addressIndex == loopCount + 1 else {
                    self.isChange = true
                    self.addressIndex = 0
                    self.tempAddressModels.removeAll()
                    self.createWalletAddress(num: self.addressIndex)
                    return
                }
                self.insertWalletAddressIntoDatabase()
            } else {
                self.insertWalletAddressIntoDatabase()
            }
        }).disposed(by: disposeBag)
    }
    
    public func recoverObserveWallet(_ wallet: TNWalletModel) {
        currentWallet = wallet
        if !wallet.xPubKey.isEmpty {
            createWalletAddress(num: addressIndex)
        }
    }
    
    private func createWalletAddress(num: Int) {
        let tempLoopCount = self.isGenerateFrontAddress ? loopCount + 1 : loopCount
        walletViewModel.generateWalletAddress(wallet_xPubKey: currentWallet!.xPubKey, change: isChange, num: num, comletionHandle: { (walletAddressModel) in
            self.tempAddressModels.append(walletAddressModel)
            self.addressIndex += 1
            if self.tempAddressModels.count == tempLoopCount {
                self.addressModels += self.tempAddressModels
                self.getHistoryTransaction()
            } else {
                self.createWalletAddress(num: self.addressIndex)
            }
        })
    }
    
    private func getHistoryTransaction() {
        
        var addresses: [String] = []
        for addressModel in tempAddressModels {
            addresses.append(addressModel.walletAddress)
        }
        guard !addresses.isEmpty else {
            return
        }
        TNHubViewModel.getMyTransactionHistory(addresses: addresses)
    }
    
    private func insertWalletAddressIntoDatabase() {
        for addressModel in addressModels {
            walletViewModel.insertWalletAddressToDatabase(walletAddressModel: addressModel)
        }
        let viewModel = TNWalletBalanceViewModel()
        viewModel.queryAllWallets { _ in
            let notificationName = Notification.Name(rawValue: TNDidFinishRecoverWalletNotification)
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
    }
}

