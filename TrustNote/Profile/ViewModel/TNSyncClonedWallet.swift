//
//  TNSyncClonedWallet.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/30.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import RxSwift

class TNSyncClonedWallet {
    
    let disposeBag = DisposeBag()
    public  var isRecoverWallet = true
    private var addressModels: [TNWalletAddressModel] = []
    private var wallets: [TNWalletModel] = []
    private var tempAddressModels: [TNWalletAddressModel] = []
    private var addressIndex = 0
    private var isChange = false
    private let walletViewModel = TNWalletViewModel()
    private var currentWallet: TNWalletModel?
    
    required init() {
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNDidReceiveRestoreWalletResponse), object: nil).subscribe(onNext: {[unowned self] (notify) in
            guard self.isRecoverWallet else {return}
            let response = notify.object as! [String : Any]
            guard response.isEmpty else {
                self.addressModels += self.tempAddressModels
                self.tempAddressModels.removeAll()
                self.createWalletAddresses(num: self.addressIndex)
                return
            }
            if !self.isChange {
                self.addressIndex = 0
                self.isChange = true
                self.tempAddressModels.removeAll()
                self.handleWallet(wallet: self.wallets.first!, isChange: self.isChange)
            } else {
                self.wallets.removeFirst()
                guard self.wallets.isEmpty else {
                    self.addressIndex = 0
                    self.isChange = false
                    self.tempAddressModels.removeAll()
                    self.handleWallet(wallet: self.wallets.first!, isChange: self.isChange)
                    return
                }
                self.saveData()
            }
            
        }).disposed(by: disposeBag)
    }
}

extension TNSyncClonedWallet {
    
    func syncClonedWallets() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let credentials  = TNConfigFileManager.sharedInstance.readWalletCredentials()
        for dict in credentials {
            let walletModel = TNWalletModel.deserialize(from: dict)
            wallets.append(walletModel!)
        }
        currentWallet = wallets.first!
        handleWallet(wallet: wallets.first!, isChange: isChange)
    }
    
    func handleWallet(wallet: TNWalletModel, isChange: Bool) {
        let is_change = isChange ? 1 : 0
        let sql = "SELECT address FROM my_addresses WHERE wallet=? AND is_change=?"
        TNSQLiteManager.sharedManager.queryWalletAddress(sql: sql, walletId: wallet.walletId, isChange: is_change) {[unowned self] (results) in
            self.addressIndex = results.count
            self.createWalletAddresses(num: self.addressIndex)
        }
    }
    
    func createWalletAddresses(num: Int) {
        walletViewModel.generateWalletAddress(wallet_xPubKey: currentWallet!.xPubKey, change: self.isChange, num: num) { (walletAddressModel) in
            self.addressIndex += 1
            var model = walletAddressModel
            model.walletId = self.currentWallet!.walletId
            self.tempAddressModels.append(model)
            guard self.tempAddressModels.count == loopCount * 2 else {
                self.createWalletAddresses(num: self.addressIndex)
                return
            }
            self.getHistoryTransaction()
        }
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
    private func saveData() {
        for addressModel in addressModels {
            walletViewModel.insertWalletAddressToDatabase(walletAddressModel: addressModel)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        let viewModel = TNWalletBalanceViewModel()
        viewModel.queryAllWallets { _ in
            let notificationName = Notification.Name(rawValue: TNDidFinishRecoverWalletNotification)
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
    }
}
