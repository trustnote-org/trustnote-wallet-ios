//
//  TNSyncWalletData.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/29.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

class TNSyncWalletData {
    
    func syncWalletsData(wallets: Array<TNWalletModel>) {
        
    }
    
    func queryWalletAllAddress(walletId: String) {
        let addressList = TNSQLiteManager.sharedManager.queryWalletAllAddresses(walletId: walletId)
        let recievedAddressList =  addressList.filter { return $0.is_change == false}
        let changeAddressList = addressList.filter { return $0.is_change == true}
    }
}
