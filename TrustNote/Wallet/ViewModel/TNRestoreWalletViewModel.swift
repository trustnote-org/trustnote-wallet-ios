//
//  TNRestoreWalletViewModel.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/28.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

let loopCount: Int = 20

class TNRestoreWalletViewModel {
   
    public var isRecoverWallet = true
    
    var restoreFailureBlock: (() -> Void)?
    
    private var addressModels: [TNWalletAddressModel] = []
    private var wallets: [TNWalletModel] = []
    private var tempAddressModels: [TNWalletAddressModel] = []
    private let walletViewModel = TNWalletViewModel()
   
    private var isExistEmptyWallet = false
    private var addressDict: [String: TNWalletAddressModel] = [:]
    private var recievedAddressIndex = 1
    private var changedAddressIndex = 0
    private var isInterrupt = false
   
    //
    public func createNewWalletWhenRestoreWallet() {
        let num = wallets.count
        TNSyncOperationManager.shared.generateNewWallet(num)
        generateWalletBySerialNumber(num)
        createWalletFirstAddress()
    }
    
    private func createWalletFirstAddress() {
        let walletAddressModel = TNSyncOperationManager.shared.generateWalletAddress(wallet_xPubKey: TNGlobalHelper.shared.currentWallet.xPubKey, change: false, num: 0)
        addressDict[TNGlobalHelper.shared.currentWallet.walletId] = walletAddressModel
        getFirstAddressHistoryTransaction(addresses: [walletAddressModel.walletAddress])
    }
    
    private func getFirstAddressHistoryTransaction(addresses: Array<String>) {
        
        let response = TNSyncOperationManager.shared.getLightHistory(addresses: addresses)
        guard !response.keys.contains("timeout") else {
            deleteCache()
            restoreFailureBlock?()
            return
        }
        if response.isEmpty {
            guard isExistEmptyWallet else {
                isExistEmptyWallet = true
                createNewWalletWhenRestoreWallet()
                return
            }
            isExistEmptyWallet = false
            filterValidWallets()
        } else {
            isExistEmptyWallet = false
            createNewWalletWhenRestoreWallet()
        }
    }
    
    private func filterValidWallets() {
        var validWallets: Array<TNWalletModel> = []
        if wallets.count > 2 {
            let index = wallets.count - 2
            validWallets = Array<TNWalletModel>(wallets[..<index])
        } else {
            validWallets = [wallets.first] as! Array<TNWalletModel>
        }
        
        saveWalletData(wallets: validWallets)
        
        for (index, wallet) in validWallets.enumerated() {
//            guard !isInterrupt else {
//                deleteCache()
//                restoreFailureBlock?()
//                break
//            }
            generateWalletAddresses(change: false, wallet: wallet)
            generateWalletAddresses(change: true, wallet: wallet)
            
            if index == validWallets.count - 1 {
                for address in addressModels {
                    walletViewModel.insertWalletAddressInBackground(walletAddressModel: address)
                }
                let viewModel = TNWalletBalanceViewModel()
                viewModel.queryAllWallets { _ in
                    let notificationName = Notification.Name(rawValue: TNDidFinishRecoverWalletNotification)
                    Preferences[.isRecoverWallet] = 3
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: notificationName, object: nil)
                    }
                }
            }
        }
    }
    
    private func saveWalletData(wallets: Array<TNWalletModel>) {
        for wallet in wallets {
            walletViewModel.saveNewWalletToProfile(wallet)
            walletViewModel.saveWalletDataToDatabase(wallet)
            
            if let walletAddress = addressDict[wallet.walletId] {
                walletViewModel.insertWalletAddressInBackground(walletAddressModel: walletAddress)
            }
        }
    }
    
    private func generateWalletAddresses(change: Bool, wallet: TNWalletModel) {
        var addressIndex = change ? changedAddressIndex : recievedAddressIndex
        var flag = true
        while flag {
            for _ in 0..<loopCount {
                var walletAddress = TNSyncOperationManager.shared.generateWalletAddress(wallet_xPubKey: wallet.xPubKey, change: change, num: addressIndex)
                walletAddress.walletId = wallet.walletId
                tempAddressModels.append(walletAddress)
                addressIndex += 1
            }
            let response = getTranscationHistory(addressesList: tempAddressModels)
            if response.isEmpty || response.keys.contains("timeout") {
                flag = false
//                if response.keys.contains("timeout") {
//                    isInterrupt = true
//                }
            } else {
                addressModels += tempAddressModels
            }
            tempAddressModels.removeAll()
        }
    }
    
    private func getTranscationHistory(addressesList: [TNWalletAddressModel]) -> [String: Any] {
        var response: [String: Any] = [:]
        if !addressesList.isEmpty {
            var addresses: [String] = []
            for addressModel in addressesList {
                addresses.append(addressModel.walletAddress)
            }
            response = TNSyncOperationManager.shared.getLightHistory(addresses: addresses)
        }
        return response
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

    private func deleteCache() {
        TNConfigFileManager.sharedInstance.updateProfile(key: "credentials", value: [])
        TNSQLiteManager.sharedManager.deleteAllLocalData()
    }
}
