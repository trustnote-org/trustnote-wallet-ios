//
//  TNChatManager.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/23.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

class TNChatManager: TNJSONSerializationProtocol {
    
    var deviceAddress = ""
    var messageHash = ""
    
    class var shared: TNChatManager {
        
        struct Static {
            static let instance: TNChatManager = TNChatManager()
        }
        return Static.instance
    }
    
    required init() {}
    
    static func reciveHubMessage() {
        TNWebSocketManager.sharedInstance.HandleHubMessageBlock = { (body) in
            DispatchQueue.global().async {
                TNChatManager.handleHubMessage(messageBody: body)
            }
        }
    }
    
    /// MARK: 处理收到hub消息内容
    static func handleHubMessage(messageBody: [String: Any]) {
        guard messageBody.keys.contains("message") else {return}
        let base64Hash = TNSyncOperationManager.shared.getRequestParamsBase64Hash(messageBody["message"] as! [String : Any])
        guard messageBody.keys.contains("message_hash") else {return}
        let messageHash = messageBody["message_hash"] as! String
        guard messageHash == base64Hash else {return}
        let messageObj = messageBody["message"] as! [String: Any]
        let ePubkey = messageObj["pubkey"] as! String
        let package = getJSONStringFrom(jsonObject: messageObj["encrypted_package"]!)
        decryptMessagePackage(package: package, ePubkey: ePubkey, messageHash: messageHash)
    }
    
    static func sendPairingMessage(isActive: Bool, secret: String, pubkey: String, hub: String) {
        let jsonBody = getMessageBody(type: .pairing, otherSecret: secret, isActive: isActive)
        sendMessage(jsonBody: jsonBody, pubkey: pubkey, hub: hub)
    }
    
    static func sendTextMessage(pubkey: String, hub: String, text: String) {
        let jsonBody = getMessageContent(type: .text, messageBody: ["body": text])
        sendMessage(jsonBody: jsonBody, pubkey: pubkey, hub: hub)
    }
    
    static func sendRemovedMessage(pubkey: String, hub: String) {
        let jsonBody = getMessageContent(type: .text, messageBody: ["body": "removed"])
        sendMessage(jsonBody: jsonBody, pubkey: pubkey, hub: hub)
    }
    
    static func sendMessage(jsonBody: [String: Any], pubkey: String, hub: String) {
        
        TNSyncOperationManager.shared.contactHub = hub
        createEncryptedPackage(packageBody: jsonBody, pubkey: pubkey)
        let tempPubkey = getTempPubkey(pubkey: pubkey)
        sendDeliverRequest(packageBody: jsonBody, tempKey: tempPubkey)
    }
    
    /// MARK:  组成消息body内容
    fileprivate static func getMessageBody(type: TNMessageType, otherSecret: String, isActive: Bool) -> [String: Any] {
        var messageBody: [String: Any] = [:]
        messageBody["pairing_secret"] = otherSecret
        messageBody["device_name"] = TNChatManager.getMyDeviceName()
        if (isActive) {
            messageBody["reverse_pairing_secret"] = TNSyncOperationManager.shared.getMySecret()
        }
        return getMessageContent(type: type, messageBody: messageBody)
    }
    
    fileprivate static func getMessageContent(type: TNMessageType, messageBody: [String: Any]) -> [String: Any] {
        var jsonBody: [String: Any] = [:]
        let myHub = TNChatManager.getMyHub()
        jsonBody["from"] = TNGlobalHelper.shared.my_device_address
        jsonBody["device_hub"] = myHub
        jsonBody["subject"] = type.rawValue
        if type == .pairing {
            jsonBody["body"] = messageBody
        } else {
            jsonBody["body"] = messageBody["body"]
        }
        TNSyncOperationManager.shared.myHub = myHub
        return jsonBody
    }
    
    /// MARK: 加密数据包
    fileprivate static func createEncryptedPackage(packageBody: [String: Any], pubkey: String) {
        let json =  TNChatManager.getJSONStringFrom(jsonObject: packageBody)
        let encryptedStr = TNSyncOperationManager.shared.createEncryptedPackage(json: json, pubkey: pubkey)
        let encryptedObj = TNChatManager.getDictionaryFromJsonString(json: encryptedStr)
        let objDeviceMessage = ["encrypted_package": encryptedObj]
        let messageHash = TNSyncOperationManager.shared.getRequestParamsBase64Hash(objDeviceMessage)
        TNChatManager.shared.messageHash = messageHash
        let messageStr = TNChatManager.getJSONStringFrom(jsonObject: objDeviceMessage)
        let createDate = NSDate.getCurrentFormatterTime()
        // 根据m/1公钥生成device_address
        let deviceAddress = TNSyncOperationManager.shared.getDeviceAddress(pubkey)
        TNChatManager.shared.deviceAddress = deviceAddress
        let sql = "INSERT INTO outbox (message_hash, `to`, message, creation_date) VALUES(?,?,?,?)"
        TNSQLiteManager.sharedManager.updateData(sql: sql, values: [messageHash, deviceAddress, messageStr, createDate])
    }
    
    /// MARK: 发送 'hub/deliver' request
    static fileprivate func sendDeliverRequest(packageBody: [String: Any], tempKey: String) {
        let json =  TNChatManager.getJSONStringFrom(jsonObject: packageBody)
        let encryptedStr = TNSyncOperationManager.shared.createEncryptedPackage(json: json, pubkey: tempKey)
        let encryptedObj = TNChatManager.getDictionaryFromJsonString(json: encryptedStr)
        var objDeviceMessage = ["encrypted_package": encryptedObj, "to": TNChatManager.shared.deviceAddress, "pubkey": TNGlobalHelper.shared.ecdsaPubkey] as [String : Any]
        let messageStr = TNChatManager.getJSONStringFrom(jsonObject: objDeviceMessage)
        let signature = TNSyncOperationManager.shared.getDeviceMessageHashToSign(unit: messageStr)
        objDeviceMessage["signature"] = signature
        let response = TNSyncOperationManager.shared.sendDeviceMessageSignature(objDeviceMessage: objDeviceMessage)
        if response == "accepted" {
            let sql = "DELETE FROM outbox WHERE message_hash=?"
            TNSQLiteManager.sharedManager.updateData(sql: sql, values: [TNChatManager.shared.messageHash])
        }
    }
    
    /// MARK: 解密数据包
    static fileprivate func decryptMessagePackage(package: String, ePubkey: String, messageHash: String) {
        let privkey = TNGlobalHelper.shared.tempDeviceKey
        let prePrivKey = TNGlobalHelper.shared.prevTempDeviceKey
        let m1PrivKey = TNGlobalHelper.shared.ecdsaPrivkey
        let decryptedJson = TNSyncOperationManager.shared.getDecryptedPackage(json: package, privkey: privkey, prePrivKey: prePrivKey, m1PrivKey: m1PrivKey)
        let decryptedObj = TNChatManager.getDictionaryFromJsonString(json: decryptedJson)
        let subject = decryptedObj["subject"] as! String
        
        switch subject {
        case TNMessageType.pairing.rawValue:
            handlePairingMessage(decryptedObj: decryptedObj, ePubkey: ePubkey, messageHash: messageHash)
        case TNMessageType.remove.rawValue:
            handleDeleteContactMessage(decryptedObj: decryptedObj)
        case TNMessageType.text.rawValue:
            handleRecieveTextMessage(decryptedObj: decryptedObj)
        default:
            break
        }
    }
}

extension TNChatManager {
    
    static fileprivate func handlePairingMessage(decryptedObj: [String: Any], ePubkey: String, messageHash: String) {
        let from = decryptedObj["from"] as! String
        let sql = String(format:"SELECT Count(*) FROM correspondent_devices WHERE device_address = '%@'", arguments:[from])
        let deviceHub = decryptedObj["device_hub"] as! String
        let body = decryptedObj["body"] as! [String: String]
        let deviceName = body["device_name"]
        let createDate = NSDate.getCurrentFormatterTime()
        let count = TNSyncOperationManager.shared.queryCount(sql: sql)
        if count == 0 {
            let sql = "INSERT INTO correspondent_devices (device_address, name, pubkey, hub, creation_date,is_confirmed) VALUES(?,?,?,?,?,1)"
            TNSQLiteManager.sharedManager.updateData(sql: sql, values: [from, deviceName!, ePubkey, deviceHub, createDate])
            sendPairingMessage(isActive: false, secret: body["pairing_secret"]!, pubkey: ePubkey, hub: deviceHub)
        } else {
            let sql = "UPDATE correspondent_devices SET is_confirmed=1, name=? WHERE device_address=? AND is_confirmed=0"
            TNSQLiteManager.sharedManager.updateData(sql: sql, values: [deviceName!, from])
        }
        TNHubViewModel.deleteHubCache(messageHash: messageHash)
    }
    
    static fileprivate func handleDeleteContactMessage(decryptedObj: [String: Any]) {
        
    }
    
    static fileprivate func handleRecieveTextMessage(decryptedObj: [String: Any]) {
        let createDate = NSDate.getCurrentFormatterTime()
        NotificationCenter.default.post(name: Notification.Name(rawValue: TNDidRecievedMessageNotification), object: ["decryptedObj": decryptedObj, "createDate": createDate])
        TNSQLiteManager.sharedManager.updateChatMessagesTable(address: decryptedObj["from"] as! String, message: decryptedObj["body"] as! String, date: createDate, isIncoming: 1, type: TNMessageType.text.rawValue)
    }
}

extension TNChatManager {
    static fileprivate func getMyHub() -> String {
        let config = TNConfigFileManager.sharedInstance.readConfigFile()
        let myHub = config["hub"] as! String
        return myHub
    }
    
    static fileprivate func getMyDeviceName() -> String {
        let config = TNConfigFileManager.sharedInstance.readConfigFile()
        let deviceName = config["deviceName"] as! String
        return deviceName
    }
    
    static fileprivate func getTempPubkey(pubkey: String) -> String {
        let connnect = TNSyncOperationManager.shared.openSocket()
        if (connnect == "connected") {
            let otherTempPubkey = TNSyncOperationManager.shared.getOherTempPubkeyFromHub(pubkey: pubkey)
            return otherTempPubkey
        }
        return ""
    }
}
