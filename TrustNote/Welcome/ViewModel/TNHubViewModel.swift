//
//  TNHubViewModel.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/17.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

struct TNHubViewModel {
    
   var hubAddress: String {
    
       get {
         let defaultConfigList = TNConfigFileManager.sharedInstance.readConfigFile() as NSDictionary
         return defaultConfigList.object(forKey: "hub") as! String
       }
       set {}
    }
    
    static func loginHub() {
        guard let challenge = TNWebSocketManager.sharedInstance.challenge else {return}
        guard !TNGlobalHelper.shared.ecdsaPubkey.isEmpty else {return}
        TNWebSocketManager.loginHub(challenge: challenge, pubkey: TNGlobalHelper.shared.ecdsaPubkey)
    }
    
    static func sendTempPubkeyToHub() {
        
        guard !TNGlobalHelper.shared.tempPublicKey.isEmpty else {return}
        guard !TNGlobalHelper.shared.ecdsaPubkey.isEmpty else {return}
        TNWebSocketManager.sendTemporaryPublicKeyToHub(TNGlobalHelper.shared.tempPublicKey, pubkey: TNGlobalHelper.shared.ecdsaPubkey)
    }
    
    static func sendVersionToHub() {
        TNWebSocketManager.sendClientVersion()
    }
    
    static func getMyWitnessesList() {
        TNWebSocketManager.getMyWitnessFromHub()
    }
    
    static func getMyTransactionHistory(addresses: [String], isRecoverWallet: Bool) {
        
        guard TNGlobalHelper.shared.witnesses.count > 0 else {
            return
        }
        TNWebSocketManager.getTransactionHistoryRecords(witnesses: TNGlobalHelper.shared.witnesses, addresses: addresses, requested_joints: nil, known_stable_units: nil)
    }
}
