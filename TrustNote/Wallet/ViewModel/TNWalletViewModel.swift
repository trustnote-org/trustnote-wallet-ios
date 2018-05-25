//
//  TNWalletViewModel.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/24.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import HandyJSON
import SwiftyJSON

final class TNWalletViewModel {
    
    private let currentWallet = TNGlobalHelper.shared.currentWallet
    
    private var curWalletAddress: TNWalletAddressModel?
}
extension TNWalletViewModel {
    /// create a new wallet
    public func generateNewWalletByDatabaseNumber(isLocal: Bool, comletionHandle: (() -> Swift.Void)?) {
        
        TNGlobalHelper.shared.currentWallet.isLocal = isLocal
        guard isLocal else {
            return
        }
        readNextAccount(isLocal: isLocal) { (accountIndex) in
           self.generateNewWallet(accountIndex, comletionHandle: comletionHandle)
        }
    }
    
    public func generateNewWallet(_ accountIndex: Int,  comletionHandle: (() -> Swift.Void)?) {
        TNEvaluateScriptManager.sharedInstance.getWalletPubkey(xPrivKey: TNGlobalHelper.shared.xPrivKey, num: accountIndex) {
            TNGlobalHelper.shared.currentWallet.account = accountIndex
            TNGlobalHelper.shared.currentWallet.publicKeyRing = [["xPubKey":TNGlobalHelper.shared.currentWallet.xPubKey]]
            TNGlobalHelper.shared.currentWallet.creation_date = NSDate.getCurrentFormatterTime()
            comletionHandle!()
        }
    }
    
    private func readNextAccount(isLocal: Bool, comletionHandle: ((Int) -> Swift.Void)?) {
        
        let is_local = isLocal ? 1 : 0
        let sql = String(format:"SELECT Count(*) FROM wallets WHERE is_local = %d", arguments:[is_local])
        TNSQLiteManager.sharedManager.queryCount(sql: sql, completionHandle: comletionHandle)
    }
    
    /// insert new wall to sqlite
    public func insertNewWalletToDatabase(wallet: TNWalletModel) {
        
        let querySQL = String(format:"SELECT Count(*) FROM wallets WHERE wallet = '%@'", arguments:[wallet.walletId])
        TNSQLiteManager.sharedManager.queryCount(sql: querySQL) { (count) in
            guard count == 0 else {return}
            let definition_template = ["sig", ["pubkey" : wallet.xPubKey]] as [Any]
            let creation_date = wallet.creation_date
            let isLocal = wallet.isLocal ? 1:0
            let sql = "INSERT INTO wallets (wallet, account, definition_template, creation_date, full_approval_date, ready_date, is_local) VALUES(?,?,?,?,?,?,?)"
            TNSQLiteManager.sharedManager.updateData(sql: sql, values: [wallet.walletId, wallet.account, "\(JSON(definition_template))", creation_date, creation_date, creation_date, isLocal])
        }
    }
    
    public func insertDataIntoExtendedPubkey(wallet: TNWalletModel) {
        
        let querySQL = String(format:"SELECT Count(*) FROM extended_pubkeys WHERE wallet = '%@' AND device_address = '%@'", arguments:[wallet.walletId, TNGlobalHelper.shared.my_device_address])
        TNSQLiteManager.sharedManager.queryCount(sql: querySQL) { (count) in
            guard count == 0 else {return}
            let device_address = TNGlobalHelper.shared.my_device_address
            let creation_date = wallet.creation_date
            let sql = "INSERT INTO extended_pubkeys (wallet, extended_pubkey, device_address, creation_date, approval_date, member_ready_date) VALUES(?,?,?,?,?,?)"
            TNSQLiteManager.sharedManager.updateData(sql: sql, values: [wallet.walletId, wallet.xPubKey, device_address, creation_date, creation_date, creation_date])
        }
    }
    
    public func insertDataIntoWalletSigningPath(wallet: TNWalletModel) {
        
        let querySQL = String(format:"SELECT Count(*) FROM wallet_signing_paths WHERE wallet = '%@' AND signing_path = '%@'", arguments:[wallet.walletId, "r"])
        TNSQLiteManager.sharedManager.queryCount(sql: querySQL) { (count) in
            guard count == 0 else {return}
            let device_address = TNGlobalHelper.shared.my_device_address
            let creation_date = wallet.creation_date
            let sql = "INSERT INTO wallet_signing_paths (wallet, signing_path, device_address, creation_date) VALUES(?,?,?,?)"
            TNSQLiteManager.sharedManager.updateData(sql: sql, values: [wallet.walletId, "r", device_address, creation_date])
        }
    }
    
    public func saveWalletDataToDatabase(_ wallet: TNWalletModel) {
        insertNewWalletToDatabase(wallet: wallet)
        insertDataIntoExtendedPubkey(wallet: wallet)
        insertDataIntoWalletSigningPath(wallet: wallet)
    }
    
    public func saveNewWalletToProfile(_ wallet: TNWalletModel) {
        let jsonModel = wallet.toJSON()
        let profile = TNConfigFileManager.sharedInstance.readProfileFile()
        var credentials  = profile["credentials"] as! [[String:Any]]
        credentials.append(jsonModel!)
        TNConfigFileManager.sharedInstance.updateProfile(key: "credentials", value: credentials)
    }
}

extension TNWalletViewModel {
    /// The address of the wallet
    public func generateWalletAddress(wallet_xPubKey: String, change: Bool, num: Int, comletionHandle: ((TNWalletAddressModel) -> Swift.Void)?) {
        
        var walletAddressModel = TNWalletAddressModel()
        let is_change = change ? 1 : 0
        walletAddressModel.is_change = change
        TNEvaluateScriptManager.sharedInstance.getWalletAddress(wallet_xPubKey: wallet_xPubKey, change: is_change, num: num) { (result) in
            walletAddressModel.walletAddress = result
            walletAddressModel.creation_date = NSDate.getCurrentFormatterTime()
            walletAddressModel.walletId = self.currentWallet.walletId
            self.curWalletAddress = walletAddressModel
            self.generateWalletAddressPubkey(wallet_xPubKey: wallet_xPubKey, change: is_change, num: num, comletionHandle: comletionHandle)
        }
    }
    /// Generating the public key corresponding to the address of the wallet
    public func generateWalletAddressPubkey(wallet_xPubKey: String, change: Int, num: Int, comletionHandle: ((TNWalletAddressModel) -> Swift.Void)?) {
        
        TNEvaluateScriptManager.sharedInstance.getWalletAddressPubkey(wallet_xPubKey: wallet_xPubKey, change: change, num: num) {(result) in
            self.curWalletAddress?.walletAddressPubkey = result
            comletionHandle!(self.curWalletAddress!)
        }
    }
    /// Save wallet address to core data
    public func insertWalletAddressToDatabase(walletAddressModel: TNWalletAddressModel) {
        
        let querySQL = String(format:"SELECT Count(*) FROM my_addresses WHERE address = '%@'", arguments:[walletAddressModel.walletAddress])
        TNSQLiteManager.sharedManager.queryCount(sql: querySQL) { (count) in
            guard count == 0 else {return}
            let is_change = walletAddressModel.is_change ? 1 : 0
            self.readNextAddressIndex(walletId: walletAddressModel.walletId, is_change: is_change) { (address_index) in
                let definition = ["sig", ["pubkey":walletAddressModel.walletAddressPubkey]] as [Any]
                let is_change = walletAddressModel.is_change
                let sql = "INSERT INTO my_addresses (wallet, address, is_change, creation_date, definition, address_index) VALUES(?,?,?,?,?,?)"
                TNSQLiteManager.sharedManager.updateData(sql: sql, values: [walletAddressModel.walletId, walletAddressModel.walletAddress, is_change, walletAddressModel.creation_date!, "\(JSON(definition))", address_index])
            }
        }
    }
    
    private func readNextAddressIndex(walletId: String, is_change: Int, comletionHandle: ((Int) -> Swift.Void)?) {
        
        let sql = String(format:"SELECT Count(*) FROM my_addresses WHERE wallet = '%@' AND is_change = %d", arguments: [walletId, is_change])
        TNSQLiteManager.sharedManager.queryCount(sql: sql, completionHandle: comletionHandle)
    }
}
