//
//  TNWebSocketManager+API.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/14.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import SwiftyJSON
import HandyJSON

protocol JSONStringFromDictionaryProtocol {}

extension JSONStringFromDictionaryProtocol {
    
    static func getJSONStringFromDictionary(dictionary: NSDictionary) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            TNDebugLogManager.debugLog(item: "ERROR")
            return ""
        }
        let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData!
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
        
    }
}

extension TNWebSocketManager: JSONStringFromDictionaryProtocol {
    /**
     *  Method send version to hub
     *  @param
     */
    static func sendClientVersion() {
       
        let sendBody: [String : Any] = ["subject":"version", "body":["protocol_version": "1.0", "alt": "1", "library": "trustnote-common", "library_version":"0.1.0", "program":"TTT", "program_version":"1.1.0"]]
            
        let request: [Any] = ["justsaying", sendBody]
        TNWebSocketManager.sharedInstance.sendData("\(JSON(request))")
    }
    
    /**
     *  Method get witnesses from hub
     *  @param
     */
    static func getMyWitnessFromHub() {
        let params: [String : Any] = ["command":"get_witnesses"]
        TNWebSocketManager.getRequestParamsBase64Hash(params) { (objectHash) in
            
            TNWebSocketManager.sharedInstance.responseTag.getWitnessTag = objectHash
            let requestbody: [String : Any] = ["command":"get_witnesses", "tag":objectHash]
            let request: [Any] = ["request", requestbody]
            TNWebSocketManager.sharedInstance.sendData("\(JSON(request))")
        }
        TNWebSocketManager.sharedInstance.GetWitnessCompletionBlock = { (anyObject) in
    
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
    
    /**
     *  Method login hub
     *
     *  @param challenge
     *  @param pubkey
     *  @param signature
     */
    static func loginHub(challenge: String, pubkey: String) {
        
        let unit: NSDictionary = ["challenge":challenge, "pubkey":pubkey]
        let unitString = TNWebSocketManager.getJSONStringFromDictionary(dictionary: unit)
        TNEvaluateScriptManager.sharedInstance.getParamsSignForLoginHub(unit: unitString) { (signature) in
            let requestBody: [String : Any] = ["subject":"hub/login", "body":["challenge":challenge, "pubkey":pubkey, "signature":signature]]
            let request: [Any] = ["justsaying", requestBody]
            TNWebSocketManager.sharedInstance.sendData("\(JSON(request))")
        }
    }
    
    /**
     *  Method send temp_pubkey
     *  @param temp_pubkey
     *  @param pubkey  m/1 sign pubkey
     */
    static func sendTemporaryPublicKeyToHub(_ temp_pubkey: String, pubkey: String) {
        
        let unit: NSDictionary = ["temp_pubkey":temp_pubkey, "pubkey":pubkey]
        let unitString = TNWebSocketManager.getJSONStringFromDictionary(dictionary: unit)
        TNEvaluateScriptManager.sharedInstance.getParamsSignForSendingTempPubkey(unit: unitString) {(signature) in
            
            var request: [String : Any] = ["command":"hub/temp_pubkey"]
            let params: [String : Any] = ["temp_pubkey":temp_pubkey, "pubkey":pubkey, "signature":signature]
            request["params"] = params
            TNWebSocketManager.getRequestParamsBase64Hash(request, completionHandler: { (objectHash) in
                 TNWebSocketManager.sharedInstance.responseTag.tempPubkeyTag = objectHash
                let requestBody: [String : Any] = ["command": "hub/temp_pubkey", "params":params, "tag": objectHash]
                let requestParams: [Any] = ["request", requestBody]
                TNWebSocketManager.sharedInstance.sendData("\(JSON(requestParams))")
            })
        }
        
        TNWebSocketManager.sharedInstance.SendTempPubkeyCompletionBlock = { _ in
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
    
    /**
     *  Method query transaction history records
     *  @param witnesses
     *  @param addresses
     *  @param requested_joints   // Unstable element array
     *  @param known_stable_units // Stable unit array
     */
    static func getTransactionHistoryRecords(witnesses: [String], addresses: [String], requested_joints: [String]?, last_stable_mci: Int = 0, known_stable_units: [String]?) {
        
        var request: [String : Any] = ["command":"light/get_history"]
        var params: [String: Any] = ["witnesses":witnesses, "addresses":addresses, "last_stable_mci":last_stable_mci]
        if let joints = requested_joints {
            params["requested_joints"] = joints
        }
        if let units = known_stable_units {
            params["known_stable_units"] = units
        }
        request["params"] = params
        
        var requestJsonStr: String?
        
        TNWebSocketManager.getRequestParamsBase64Hash(request) { (objectHash) in
             TNWebSocketManager.sharedInstance.responseTag.getHistoryTag = objectHash
            let requestBody: [String : Any] = ["command": "light/get_history", "params":params, "tag": objectHash]
            let requestParams: [Any] = ["request", requestBody]
            requestJsonStr = "\(JSON(requestParams))"
            TNWebSocketManager.sharedInstance.sendData(requestJsonStr!)
        }
        TNTimerHelper.shared.scheduledDispatchTimer(WithTimerName: kGetHistoryTimer, timeInterval: 1.0, queue: .main, repeats: true) {
            TNWebSocketManager.sharedInstance.timeConsume += 1
            guard TNWebSocketManager.sharedInstance.isCompleted else {
                if TNWebSocketManager.sharedInstance.timeConsume == kNetworkTimeout {
                    TNWebSocketManager.sharedInstance.sendData(requestJsonStr!)
                }
                return
            }
            TNWebSocketManager.sharedInstance.isCompleted = false
            TNWebSocketManager.sharedInstance.timeConsume = 0
            TNTimerHelper.shared.cancleTimer(WithTimerName: kGetHistoryTimer)
        }
        
        TNWebSocketManager.sharedInstance.GetHistoryCompletionBlock = { (anyObject) in
           
            TNWebSocketManager.sharedInstance.isCompleted = true
            if TNWebSocketManager.sharedInstance.is_getting_history {
                
                TNWebSocketManager.sharedInstance.is_getting_history = false
                let notificationName = Notification.Name(rawValue: TNDidFinishedGetHistoryTransaction)
                NotificationCenter.default.post(name: notificationName, object: nil)
            } else {
                let notificationName = Notification.Name(rawValue: TNDidReceiveRestoreWalletResponse)
                NotificationCenter.default.post(name: notificationName, object: anyObject)
            }
            let model = TNHistoryTransactionModel.deserialize(from: anyObject as? [String : Any] )
            let historyRecordsViewModel = TNHistoryRecordsViewModel()
            historyRecordsViewModel.historyTransactionModel = model!
            historyRecordsViewModel.processingTheAcquiredData()
        }
    }
}

extension TNWebSocketManager {
    
    static func getRequestParamsBase64Hash(_ request: [String : Any], completionHandler: ((String) -> Void)?) {
        let unit = TNWebSocketManager.getJSONStringFromDictionary(dictionary: request as NSDictionary)
        
        TNEvaluateScriptManager.sharedInstance.getBase64Hash(unit, completionHandler: completionHandler)
    }
}
