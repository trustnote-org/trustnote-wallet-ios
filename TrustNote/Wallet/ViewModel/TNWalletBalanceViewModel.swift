//
//  TNWalletBalanceViewModel.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/16.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

class TNWalletBalanceViewModel: NSObject {
    
    var wallets: [TNWalletModel] = []
    var credentials: [[String:Any]] = []
    
    func queryAllWallets(completion: @escaping ([TNWalletModel]) ->Void) {
        let profile = TNConfigFileManager.sharedInstance.readProfileFile()
        let credentials  = profile["credentials"] as! [[String:Any]]
        for dict in credentials {
            let walletModel = TNWalletModel.deserialize(from: dict)
            wallets.append(walletModel!)
        }
        for (index, wallet) in wallets.enumerated() {
            calculatAllWalletsBalance(wallet, num: index, completion: completion)
        }
    }
    
    func calculatAllWalletsBalance(_ wallet: TNWalletModel, num: Int, completion: @escaping ([TNWalletModel]) ->Void) {
        
        TNSQLiteManager.sharedManager.queryAmountFromOutputs(walletId: wallet.walletId) { (results) in
            var balance: Int = 0
            for balanceModel in results as! [TNWalletBalance] {
                balance += Int(balanceModel.amount)!
            }
            let fBalance = Double(balance) / 1000000.0
            wallet.balance = String(format: "%.4f", fBalance)
            self.credentials.append(wallet.toJSON()!)
            if num == self.wallets.count - 1 && !self.wallets.isEmpty {
                TNConfigFileManager.sharedInstance.updateProfile(key: "credentials", value: self.credentials)
                completion(self.wallets)
            }
        }
    }
    
    func calculatBalance(_ wallet: TNWalletModel, completion: @escaping (TNWalletModel) ->Void) {
         TNSQLiteManager.sharedManager.queryAmountFromOutputs(walletId: wallet.walletId) { (results) in
            var balance: Int = 0
            for balanceModel in results as! [TNWalletBalance] {
                balance += Int(balanceModel.amount)!
            }
            let fBalance = Double(balance) / 1000000.0
            wallet.balance = String(format: "%.4f", fBalance)
            completion(wallet)
        }
    }
}
