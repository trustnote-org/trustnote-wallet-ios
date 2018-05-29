//
//  TNSynchroData.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/21.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxSwift

class TNSynchroHistoryData {
    
    let disposeBag = DisposeBag()
    private var addressIndex = 0
    var operationWallets: [TNWalletModel] = []
    var is_change_address = false
    var currentWallet: TNWalletModel?
    var existAddressCount = 0
    var addressArr: [TNWalletAddressModel] = []
    var tempAddressModels: [TNWalletAddressModel] = []
    var existChangeAddressCount = 0
    var changeAddressArr: [TNWalletAddressModel] = []
    var tempChangeAddressModels: [TNWalletAddressModel] = []
    var isFrontWalletAddresses = true
    let walletViewModel = TNWalletViewModel()
    
    required init() {
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNDidFinishedGetHistoryTransaction), object: nil).subscribe(onNext: {[unowned self] (notify) in
            guard !TNGlobalHelper.shared.isRecoveringObserveWallet else {return}
            let response = notify.object as! [String : Any]
            guard !self.is_change_address  else {
                guard !response.isEmpty else {
                    self.existAddressCount = 0
                    self.existChangeAddressCount = 0
                    self.tempChangeAddressModels.removeAll()
                    self.isFrontWalletAddresses = true
                    self.is_change_address = false
                    self.insertWalletAddressIntoDatabase()
                    return
                }
                self.changeAddressArr += self.tempChangeAddressModels
                self.tempChangeAddressModels.removeAll()
                self.createWalletAddress(num: self.existChangeAddressCount)
                return
            }
            if self.isFrontWalletAddresses {
                self.createWalletAddress(num: self.existAddressCount)
                self.isFrontWalletAddresses = false
            } else {
                guard !response.isEmpty else {
                    self.tempAddressModels.removeAll()
                    self.is_change_address = true
                    self.queryAllAddresses(walletId: (self.currentWallet?.walletId)!, isChange: self.is_change_address)
                    return
                }
                self.addressArr += self.tempAddressModels
                self.tempAddressModels.removeAll()
                self.createWalletAddress(num: self.existAddressCount)
            }
            
        }).disposed(by: disposeBag)
    }
    
    func syncHistoryData(wallets: [TNWalletModel]) {
        guard !TNGlobalHelper.shared.isRecoveringCommonWallet && !TNGlobalHelper.shared.isRecoveringObserveWallet else {
            return
        }
        guard operationWallets.isEmpty else {
            let walletsArr = operationWallets as NSArray
            for walletModel in wallets {
                if walletsArr.contains(walletModel) {
                    continue
                }
                walletsArr.adding(walletModel)
            }
            operationWallets = walletsArr as! [TNWalletModel]
            return
        }
        operationWallets += wallets
        guard !operationWallets.isEmpty else {
            return
        }
        currentWallet = operationWallets.first
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        queryAllAddresses(walletId: currentWallet!.walletId, isChange: is_change_address)
    }
    
    private func queryAllAddresses(walletId: String, isChange: Bool) {
        let is_change = isChange ? 1 : 0
        let sql = "SELECT address FROM my_addresses WHERE wallet=? AND is_change=?"
        TNSQLiteManager.sharedManager.queryWalletAddress(sql: sql, walletId: walletId, isChange: is_change) {[unowned self] (results) in
            
            if isChange {
                if !results.isEmpty {
                    self.existChangeAddressCount = results.count
                    TNHubViewModel.getMyTransactionHistory(addresses: results)
                } else {
                    self.createWalletAddress(num: 0)
                }
            } else {
                if !results.isEmpty {
                    self.existAddressCount = results.count
                    TNHubViewModel.getMyTransactionHistory(addresses: results)
                } else {
                    self.createWalletAddressWhenNone(num: 0)
                }
            }
        }
    }
    
    private func createWalletAddress(num: Int) {
        
        walletViewModel.generateWalletAddress(wallet_xPubKey: currentWallet!.xPubKey, change: is_change_address, num: num) { (walletAddressModel) in
            
            let addressIndex = num + 1
            var model: TNWalletAddressModel = walletAddressModel
            model.walletId = self.currentWallet!.walletId
            if self.is_change_address {
                self.tempChangeAddressModels.append(model)
                guard self.tempChangeAddressModels.count == loopCount else {
                    self.createWalletAddress(num: addressIndex)
                    return
                }
                self.existChangeAddressCount += loopCount
                self.getHistoryTransaction(self.tempChangeAddressModels)
            } else {
                self.tempAddressModels.append(model)
                guard self.tempAddressModels.count == loopCount else {
                    self.createWalletAddress(num: addressIndex)
                    return
                }
                self.existAddressCount += 20
                self.getHistoryTransaction(self.tempAddressModels)
            }
        }
    }
    
    private func createWalletAddressWhenNone(num: Int) {
        walletViewModel.generateWalletAddress(wallet_xPubKey: currentWallet!.xPubKey, change: is_change_address, num: num) {[unowned self] (walletAddressModel) in
            let addressIndex = num + 1
             var model: TNWalletAddressModel = walletAddressModel
            model.walletId = self.currentWallet!.walletId
            if !self.is_change_address {
                self.tempAddressModels.append(model)
                if self.tempAddressModels.count == loopCount {
                    self.addressArr += self.tempAddressModels
                    self.existAddressCount = self.addressArr.count
                    self.getHistoryTransaction(self.tempAddressModels)
                    self.tempAddressModels.removeAll()
                    self.addressIndex = 0
                } else {
                    self.createWalletAddress(num: addressIndex)
                }
            }
        }
    }
    
    private func getHistoryTransaction(_ addressModels: [TNWalletAddressModel]) {
        
        var addresses: [String] = []
        if is_change_address {
            for addressModel in tempChangeAddressModels {
                addresses.append(addressModel.walletAddress)
            }
        } else {
            for addressModel in tempAddressModels {
                addresses.append(addressModel.walletAddress)
            }
        }
        guard !addresses.isEmpty else {
            return
        }
        TNHubViewModel.getMyTransactionHistory(addresses: addresses)
    }
    
    private func insertWalletAddressIntoDatabase() {
        for addressModel in addressArr {
            walletViewModel.insertWalletAddressToDatabase(walletAddressModel: addressModel)
        }
        for addressModel in changeAddressArr {
            walletViewModel.insertWalletAddressToDatabase(walletAddressModel: addressModel)
        }
        addressArr.removeAll()
        changeAddressArr.removeAll()
        operationWallets.removeFirst()
        guard !operationWallets.isEmpty else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return
        }
        currentWallet = operationWallets.first
        queryAllAddresses(walletId: currentWallet!.walletId, isChange: is_change_address)
    }
}
