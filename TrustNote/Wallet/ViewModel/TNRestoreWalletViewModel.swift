//
//  TNRestoreWalletViewModel.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/28.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import RxSwift

let loopCount: Int = 20

class TNRestoreWalletViewModel {
   
    let disposeBag = DisposeBag()
    public var isRecoverWallet = true
    private var isGenerateFrontAddress = true
    private var addressModels: [TNWalletAddressModel] = []
    private var wallets: [TNWalletModel] = []
    private var tempAddressModels: [TNWalletAddressModel] = []
    private let walletViewModel = TNWalletViewModel()
    private var addressIndex = 0
    private var isChange = false
    
    required init() {
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNDidReceiveRestoreWalletResponse), object: nil).subscribe(onNext: {[unowned self] (notify) in
            guard self.isRecoverWallet else {return}
            let response = notify.object as! [String : Any]
            guard response.count == 0 else {
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
                self.saveData()
            } else {
                self.isChange = false
                self.addressIndex = 0
                self.tempAddressModels.removeAll()
                self.isGenerateFrontAddress = true
                self.createNewWalletWhenRestoreWallet()
            }

        }).disposed(by: disposeBag)
    }
    
    public func createNewWalletWhenRestoreWallet() {
        let num = wallets.count
        walletViewModel.generateNewWallet(num) {
            if !TNGlobalHelper.shared.currentWallet.xPubKey.isEmpty {
                self.generateWalletBySerialNumber(num)
                self.createWalletAddress(num: self.addressIndex)
            }
        }
    }
    
    private func createWalletAddress(num: Int) {
        let tempLoopCount = self.isGenerateFrontAddress ? loopCount + 1 : loopCount
        walletViewModel.generateWalletAddress(wallet_xPubKey: TNGlobalHelper.shared.currentWallet.xPubKey, change: self.isChange, num: num, comletionHandle: { (walletAddressModel) in
            self.tempAddressModels.append(walletAddressModel)
            self.addressIndex += 1
            if self.tempAddressModels.count ==  tempLoopCount {
                self.addressModels += self.tempAddressModels
                self.getHistoryTransaction()
                self.isGenerateFrontAddress = false
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
    
    private func generateWalletBySerialNumber(_ walletIndex: Int) {
        let wallet = TNWalletModel()
        wallet.account = walletIndex
        wallet.walletId = TNGlobalHelper.shared.currentWallet.walletId
        wallet.xPubKey = TNGlobalHelper.shared.currentWallet.xPubKey
        wallet.creation_date = NSDate.getCurrentFormatterTime()
        wallet.publicKeyRing = [["xPubKey":TNGlobalHelper.shared.currentWallet.xPubKey]]
        wallets.append(wallet)
    }
    
    private func saveData() {
       
        if wallets.count > 1 {
            wallets.removeLast()
            let index = addressModels.count - (loopCount + 1)
            let newAddressModels = addressModels[..<index]
            for address in newAddressModels {
                walletViewModel.insertWalletAddressToDatabase(walletAddressModel: address)
            }
        } else {
            walletViewModel.insertWalletAddressToDatabase(walletAddressModel: addressModels.first!)
        }
        for wallet in wallets {
            walletViewModel.saveWalletDataToDatabase(wallet)
            walletViewModel.saveNewWalletToProfile(wallet)
        }
        let viewModel = TNWalletBalanceViewModel()
        viewModel.queryAllWallets { _ in
            let notificationName = Notification.Name(rawValue: TNDidFinishRecoverWalletNotification)
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
    }
}
