//
//  TNGlobalHelper.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/22.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

final class TNGlobalHelper {
    
    var isComlpetion: Bool = false
    var isNeedGenerateSeed: Bool = false
    
    var xPrivKey: String = ""            // root privatekey
    var xPubkey: String = ""             // root publickey
    var tempDeviceKey: String = ""       // temp privateKey
    var tempPublicKey:String  = ""       // temp publicKey
    var prevTempDeviceKey: String = ""   // previous temp privatekey
    var mnemonic: String? = nil           //
    var ecdsaPubkey: String = ""
    var my_device_address: String = ""
    
    var currentWallet: TNWalletModel = TNWalletModel()
    
    var witnesses: [String] = []
    
    class var shared: TNGlobalHelper {
        
        struct Static {
            static let instance: TNGlobalHelper = TNGlobalHelper()
        }
        return Static.instance
    }
    
    public func createGlobalParameters() {
        
        guard TNConfigFileManager.sharedInstance.isExistProfileFile() else {
            return
        }
        let profile = TNConfigFileManager.sharedInstance.readProfileFile() as! [String: Any]
        if profile.keys.contains("mnemonic") {
            mnemonic = profile["mnemonic"] as? String
            TNWebSocketManager.sharedInstance.webSocketOpen() 
        }
        if profile.keys.contains("xPrivKey") {
            xPrivKey = profile["xPrivKey"] as! String
        }
        if profile.keys.contains("tempDeviceKey") {
            tempDeviceKey = profile["tempDeviceKey"] as! String
        }
        if profile.keys.contains("prevTempDeviceKey") {
            prevTempDeviceKey = profile["prevTempDeviceKey"] as! String
        }
        TNSQLiteManager.sharedManager.queryDataFromWitnesses(sql: "SELECT * FROM my_witnesses") { (results) in
            self.witnesses = results as! [String]
        }
    }
}
