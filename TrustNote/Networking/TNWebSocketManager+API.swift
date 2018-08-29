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

enum RequestCommand: String {
    case getWitnesses
    case tempPubkey
    case getHistory
    case getParentsUnits
    case postJoint
    case otherTempPubkey
    case deviceMessageSign
    case deleteHubCache
}

protocol TNJSONSerializationProtocol {}

extension TNJSONSerializationProtocol {
    
    static func getJSONStringFrom(jsonObject: Any) -> String {
        if (!JSONSerialization.isValidJSONObject(jsonObject)) {
            TNDebugLogManager.debugLog(item: "ERROR")
            return ""
        }
        let data : NSData! = try! JSONSerialization.data(withJSONObject: jsonObject, options: []) as NSData?
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
    }
    
    static func getDictionaryFromJsonString(json: String) -> [String: Any] {
        
        let jsonData: Data = json.data(using: .utf8)!
        let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! [String: Any]
        return jsonObject!
    }
}

extension TNWebSocketManager: TNJSONSerializationProtocol {
    /**
     *  Method send version to hub
     *  @param
     */
    static func sendClientVersion() {
        
        let sendBody: [String : Any] = ["subject":"version", "body":["protocol_version": "1.0", "alt": "1", "library": "trustnote-common", "library_version":"0.1.0", "program":"TTT", "program_version":"1.1.0", "new_version": TNGlobalHelper.shared.appVersion]]
        
        let request: [Any] = ["justsaying", sendBody]
        TNWebSocketManager.sharedInstance.sendData("\(JSON(request))")
    }
    
    /**
     *  Method get witnesses from hub
     *  @param
     */
    static func getMyWitnessFromHub(completion: @escaping (Any) -> Void) {
        
        TNWebSocketManager.sendRequest(api: "get_witnesses", params: [:], command: .getWitnesses, blockDict: ["callBack": completion])
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
        let unitString = TNWebSocketManager.getJSONStringFrom(jsonObject: unit)
        TNEvaluateScriptManager.sharedInstance.getParamsSign(unit: unitString) { (signature) in
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
    static func sendTemporaryPublicKeyToHub(_ temp_pubkey: String, pubkey: String, completion: @escaping (Any) -> Void) {
        
        let unit: NSDictionary = ["temp_pubkey":temp_pubkey, "pubkey":pubkey]
        let unitString = TNWebSocketManager.getJSONStringFrom(jsonObject: unit)
        
        TNEvaluateScriptManager.sharedInstance.getParamsSign(unit: unitString) { (signature) in
            let params: [String : Any] = ["temp_pubkey":temp_pubkey, "pubkey":pubkey, "signature":signature]
            TNWebSocketManager.sendRequest(api: "hub/temp_pubkey", params: params, command: .tempPubkey, blockDict: ["callBack": completion])
            
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
        
        let getHistoryCompletionBlock: HandleRequestMessageBlock = { (anyObject) in
            
            if TNGlobalHelper.shared.recoverStyle == .none {
                let notificationName = Notification.Name(rawValue: TNDidFinishedGetHistoryTransaction)
                NotificationCenter.default.post(name: notificationName, object: anyObject)
            } else {
                let notificationName = Notification.Name(rawValue: TNDidReceiveRestoreWalletResponse)
                NotificationCenter.default.post(name: notificationName, object: anyObject)
            }
            
            let model = TNHistoryTransactionModel.deserialize(from: anyObject as? [String : Any] )
            let historyRecordsViewModel = TNHistoryRecordsViewModel()
            historyRecordsViewModel.historyTransactionModel = model!
            historyRecordsViewModel.processingTheAcquiredData()
        }
        var params: [String: Any] = ["witnesses":witnesses, "addresses":addresses, "last_stable_mci":last_stable_mci]
        if let joints = requested_joints {
            params["requested_joints"] = joints
        }
        if let units = known_stable_units {
            params["known_stable_units"] = units
        }
        TNWebSocketManager.sendRequest(api: "light/get_history", params: params, command: .getHistory, blockDict: ["callBack": getHistoryCompletionBlock])
    }
    
    static func getHistoryTransaction(witnesses: [String], addresses: [String], requested_joints: [String]?, last_stable_mci: Int = 0, known_stable_units: [String]?, completion: @escaping ([String: Any]) -> Void) {
        let getHistoryCompletionBlock: HandleRequestMessageBlock = { (anyObject) in
            let jsonObj = anyObject as? [String : Any]
            completion(jsonObj!)
            DispatchQueue.main.async {
                let model = TNHistoryTransactionModel.deserialize(from:  jsonObj)
                let historyRecordsViewModel = TNHistoryRecordsViewModel()
                historyRecordsViewModel.historyTransactionModel = model!
                historyRecordsViewModel.processingTheAcquiredData()
            }
        }
        var params: [String: Any] = ["witnesses":witnesses, "addresses":addresses, "last_stable_mci":last_stable_mci]
        if let joints = requested_joints {
            params["requested_joints"] = joints
        }
        if let units = known_stable_units {
            params["known_stable_units"] = units
        }
        TNWebSocketManager.sendRequest(api: "light/get_history", params: params, command: .getHistory, blockDict: ["callBack": getHistoryCompletionBlock])
    }
    
    
    /**
     *  Method get parents
     *  @param witnesses
     *  @param
     */
    static func getParentsUnit(witnesses: [String], completion: @escaping ([String: Any]) -> Void) {
        
        TNWebSocketManager.sendRequest(api: "light/get_parents_and_last_ball_and_witness_list_unit", params: ["witnesses": witnesses], command: .getParentsUnits, blockDict: ["callBack": completion])
    }
    
    /**
     *  Method send transfer unit
     *  @param unitObject
     *  @param
     */
    static func getTransferResponse(objectJoint: [String: Any], completion: @escaping (String) -> Void) {
        
        
        TNWebSocketManager.sendRequest(api: "post_joint", params: ["unit": objectJoint], command: .postJoint, blockDict: ["callBack": completion])
    }
    
    /**
     *  Method get other temp_pubkey
     *  @param pubkey
     *  @param
     */
    static func getOtherTempPubkey(pubkey: String, completion: @escaping (String) -> Void) {
       
        TNWebSocketManager.sendRequest(api: "hub/get_temp_pubkey", params: ["": pubkey], command: .otherTempPubkey, blockDict: ["callBack": completion])
    }
    
    /**
     *  Method 'hub/deliver
     *  @param objDeviceMessage
     *  @param
     */
    static func sendDeliver(objDeviceMessage: [String: Any], messageHash: String, completion: @escaping ([String: Any]) -> Void) {
        
        TNWebSocketManager.sendRequest(api: "hub/deliver", params: ["": objDeviceMessage], command: .deviceMessageSign, blockDict: ["callBack": completion, "messageHash": messageHash])
    }
    
    static func sendDeleteRequest(messageHash: String) {
        let sendBody: [String : Any] = ["subject":"hub/delete", "body":messageHash]
        
        let request: [Any] = ["justsaying", sendBody]
        TNWebSocketManager.sharedInstance.sendData("\(JSON(request))")
    }
}

extension TNWebSocketManager {
    
    static func sendRequest(api: String, params: [String : Any], command: RequestCommand, blockDict: [String: Any]) {
        
        DispatchQueue.global().async {
            var request: [String : Any] = ["command": api]
            if !params.isEmpty {
                if params.keys.contains("") {
                    request["params"] = params[""]
                } else {
                    request["params"] = params
                }
            }
            let objectHash = TNSyncOperationManager.shared.getRequestParamsBase64Hash(request)
            var requestTask: [String: Any] = blockDict
            requestTask["command"] = command
            requestTask["tag"] = objectHash
            TNWebSocketManager.sharedInstance.requestTasks.append(requestTask)
            var requestBody: [String : Any] = ["command": api, "tag": objectHash]
            if !params.isEmpty {
                if params.keys.contains("") {
                    requestBody = ["command": api, "params": params[""]!, "tag": objectHash]
                } else {
                    requestBody = ["command": api, "params": params, "tag": objectHash]
                }
                
            }
            let requestParams: [Any] = ["request", requestBody]
            let requestJsonStr = "\(JSON(requestParams))"
            TNWebSocketManager.sharedInstance.sendData(requestJsonStr)
        }
    }
}
