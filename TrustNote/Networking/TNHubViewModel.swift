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
        TNWebSocketManager.sendTemporaryPublicKeyToHub(TNGlobalHelper.shared.tempPublicKey, pubkey: TNGlobalHelper.shared.ecdsaPubkey) { _ in
            TNGlobalHelper.shared.prevTempDeviceKey = TNGlobalHelper.shared.tempDeviceKey
            TNEvaluateScriptManager.sharedInstance.updateTempPrivKeyAndTempPubKey(completionHandler: {
                TNConfigFileManager.sharedInstance.updateProfile(key: "tempDeviceKey", value: TNGlobalHelper.shared.tempDeviceKey)
                TNConfigFileManager.sharedInstance.updateProfile(key: "prevTempDeviceKey", value: TNGlobalHelper.shared.prevTempDeviceKey)
                TNTimerHelper.shared.scheduledDispatchTimer(WithTimerName: kSendTempPubkeyTimer, timeInterval: 1.0, queue: .main, repeats: true) {
                    TNWebSocketManager.sharedInstance.tempPubkeyTimeConsume += 1
                    guard TNWebSocketManager.sharedInstance.tempPubkeyTimeConsume == kTempPubkeyInterval else {
                        return
                    }
                    TNHubViewModel.sendTempPubkeyToHub()
                    TNWebSocketManager.sharedInstance.tempPubkeyTimeConsume = 0
                    TNTimerHelper.shared.cancleTimer(WithTimerName: kSendTempPubkeyTimer)
                }
            })
        }
    }
    
    static func sendVersionToHub() {
        TNWebSocketManager.sendClientVersion()
    }
    
    static func getMyWitnessesList() {
        TNWebSocketManager.getMyWitnessFromHub { (anyObject) in
            TNGlobalHelper.shared.witnesses = anyObject as! [String]
            let listData = TNGlobalHelper.shared.witnesses
            for address in listData {
                
                let sql = String(format:"SELECT Count(*) FROM my_witnesses WHERE address = '%@'", arguments:[address])
                TNSQLiteManager.sharedManager.queryCount(sql: sql) { (count) in
                    guard count == 0 else {return}
                    TNSQLiteManager.sharedManager.updateData(sql: "INSERT INTO my_witnesses (address) VALUES(?)", values: [address])
                }
            }
        }
    }
    
    static func getMyTransactionHistory(addresses: [String]) {
        
        guard !TNGlobalHelper.shared.witnesses.isEmpty else {
            return
        }
        TNWebSocketManager.getTransactionHistoryRecords(witnesses: TNGlobalHelper.shared.witnesses, addresses: addresses, requested_joints: nil, known_stable_units: nil)
    }
    
    static func getParentsRequest(completion: @escaping ([String: Any]) -> Void) {

        TNWebSocketManager.getParentsUnit(witnesses: TNGlobalHelper.shared.witnesses, completion: completion)
    }
    
    static func transfer(objectJoint: [String: Any], completion: @escaping (String) -> Void) {
        TNWebSocketManager.getTransferResponse(objectJoint: objectJoint, completion: completion)
    }
    
    static func getOtherTempPubkey(pubkey: String, completion: @escaping (String) -> Void) {
        TNWebSocketManager.getOtherTempPubkey(pubkey: pubkey, completion: completion)
    }
    
    static func sendDeviceMessage(objDeviceMessage: [String: Any], completion: @escaping (String) -> Void) {
        TNWebSocketManager.sendDeviceMessageSign(objDeviceMessage: objDeviceMessage, completion: completion)
    }
}
