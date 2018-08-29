//
//  TNSyncWalletData.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/29.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

class TNSyncWalletData {
    
    let loopCount: Int = 20
    
    var isLoading = false
    
    var isRefresh = false
    
    var syncWalletDataComlpetion: (() -> Void)?
    
    private var recievedAddressIndex = 0
    private var changedAddressIndex = 0
    var currentWallet: TNWalletModel?
    var addressArr: [TNWalletAddressModel] = []
    var tempAddressArr: [TNWalletAddressModel] = []
    var operationWallets: [TNWalletModel] = []
    let walletViewModel = TNWalletViewModel()
    required init() {}
    
    func syncWalletsData(wallets: Array<TNWalletModel>) {
        guard !wallets.isEmpty else {
            return
        }
        isLoading = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.operationWallets += wallets
        self.currentWallet = self.operationWallets.first
        self.queryWalletAllAddress(walletId: self.currentWallet!.walletId)
    }
    
    func queryWalletAllAddress(walletId: String) {
        TNSQLiteManager.sharedManager.queryWalletAllAddresses(walletId: walletId) {[unowned self] (addressList) in
            let recievedAddressList =  addressList.filter { return $0.is_change == false}
            self.recievedAddressIndex = recievedAddressList.count
            let changeAddressList = addressList.filter { return $0.is_change == true}
            self.changedAddressIndex = changeAddressList.count
            DispatchQueue.global().async {
                self.getRecievedAddressHistory(addressesList: recievedAddressList)
                self.getChangedAddressHistory(addressesList: changeAddressList)
            }
        }
    }
    
    fileprivate func getRecievedAddressHistory(addressesList: [TNWalletAddressModel]) {
        
        _ = getTranscationHistory(addressesList: addressesList)
        if !isRefresh {
            generateWalletAddresses(change: false)
        }
    }
    
    fileprivate func getChangedAddressHistory(addressesList: [TNWalletAddressModel]) {
        
        _ = getTranscationHistory(addressesList: addressesList)
        if !isRefresh {
            generateWalletAddresses(change: true)
        } else {
            walletDataSyncCompletion()
        }
    }
    
    fileprivate func getTranscationHistory(addressesList: [TNWalletAddressModel]) -> [String: Any] {
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
    
    fileprivate func generateWalletAddresses(change: Bool) {
        var addressIndex = change ? changedAddressIndex : recievedAddressIndex
        var flag = true
        while flag {
            for i in 0..<loopCount {
                var walletAddress = TNSyncOperationManager.shared.generateWalletAddress(wallet_xPubKey: currentWallet!.xPubKey, change: change, num: addressIndex)
                walletAddress.walletId = currentWallet!.walletId
                tempAddressArr.append(walletAddress)
                addressIndex += 1
                if i != loopCount - 1 {
                    Thread.sleep(forTimeInterval: 0.05)
                }
            }
            let response = getTranscationHistory(addressesList: tempAddressArr)
            if response.isEmpty {
                flag = false
            } else {
                if response.keys.contains("timeout") {
                    DispatchQueue.main.async {
                        MBProgress_TNExtension.showViewAfterSecond(title: "请求超时")
                    }
                } else {
                    addressArr += tempAddressArr
                }
            }
            tempAddressArr.removeAll()
        }
        if change {
           walletDataSyncCompletion()
        }
    }
    
    fileprivate func walletDataSyncCompletion() {
        if !operationWallets.isEmpty {
            operationWallets.removeFirst()
        }
        guard !operationWallets.isEmpty else {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.syncWalletDataComlpetion?()
                self.isLoading = false
                self.isRefresh = false
            }
            if !addressArr.isEmpty {
                for addressModel in addressArr {
                    walletViewModel.insertWalletAddressInBackground(walletAddressModel: addressModel)
                }
            }
            return
        }
        currentWallet = operationWallets.first
        DispatchQueue.main.async {
            self.queryWalletAllAddress(walletId: self.currentWallet!.walletId)
        }
    }
}
