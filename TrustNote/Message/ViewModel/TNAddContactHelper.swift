//
//  TNAddContactHelper.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/20.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

class TNChatHelper: JSONStringFromDictionaryProtocol {
    
    var paireCode: String?
    var hub: String?
    var pubkey = ""
    var deviceAddress = ""
    var secret: String?
    
    static func getMyDeviceCode(completion: @escaping (String) -> Void) {
        TNEvaluateScriptManager.sharedInstance.generateRandomBytes(num: 9) { (randomBytes) in
            let hub = TNChatHelper.getMyHub()
            let deviceCode = TNGlobalHelper.shared.ecdsaPubkey + "@" + hub + "#" + randomBytes
            completion(deviceCode)
        }
    }
    
    static func getMyHub() -> String {
        let config = TNConfigFileManager.sharedInstance.readConfigFile()
        let myHub = config["hub"] as! String
        return myHub
    }
    
    static func getMyDeviceName() -> String {
        let config = TNConfigFileManager.sharedInstance.readConfigFile()
        let deviceName = config["deviceName"] as! String
        return deviceName
    }
    
    func addContactOperation() {
        DispatchQueue.global().async {
            self.generateDeviceAddress()
            let jsonBody = self.getMessageBody()
            self.createEncryptedPackage(packageBody: jsonBody)
            let tempPubkey = self.getTempPubkey()
            self.createEncryptedPackageWith(packageBody: jsonBody, tempKey: tempPubkey)
        }
    }
    
    fileprivate  func generateDeviceAddress() {
        let components = paireCode!.components(separatedBy: "@")
        pubkey = components.first!
        let backStr = components.last
        hub = backStr?.components(separatedBy: "#").first
        secret = backStr?.components(separatedBy: "#").last
        deviceAddress = TNSyncOperationManager.shared.getDeviceAddress(pubkey)
        let createDate = NSDate.getCurrentFormatterTime()
        let sql = "INSERT INTO correspondent_devices (device_address, name, pubkey, hub, creation_date) VALUES(?,?,?,?,?)"
        TNSQLiteManager.sharedManager.updateData(sql: sql, values: [deviceAddress, "new", components.first!, hub!, createDate])
    }
    
    fileprivate func getMessageBody() -> [String: Any] {
        var messageBody: [String: Any] = [:]
        messageBody["pairing_secret"] = secret
        messageBody["device_name"] = TNChatHelper.getMyDeviceName()
        messageBody["reverse_pairing_secret"] = TNSyncOperationManager.shared.getMySecret()
        return getMessageContent(messageBody: messageBody)
    }
    
    fileprivate func getMessageContent(messageBody: [String: Any]) -> [String: Any] {
        var jsonBody: [String: Any] = [:]
        jsonBody["from"] = TNGlobalHelper.shared.my_device_address
        jsonBody["device_hub"] = TNChatHelper.getMyHub()
        jsonBody["subject"] = "pairing"
        jsonBody["body"] = messageBody
        return jsonBody
    }
    
    fileprivate func createEncryptedPackage(packageBody: [String: Any]) {
        let json =  TNChatHelper.getJSONStringFrom(jsonObject: packageBody)
        let encryptedStr = TNSyncOperationManager.shared.createEncryptedPackage(json: json, pubkey: pubkey)
        let jsonData: Data = encryptedStr.data(using: .utf8)!
        let encryptedObj = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! [String : Any]
        let objDeviceMessage = ["encrypted_package": encryptedObj!]
        let messageHash = TNSyncOperationManager.shared.getRequestParamsBase64Hash(objDeviceMessage)
        let messageStr = TNChatHelper.getJSONStringFrom(jsonObject: objDeviceMessage)
        let createDate = NSDate.getCurrentFormatterTime()
        let sql = "INSERT INTO outbox (message_hash, `to`, message, creation_date) VALUES(?,?,?,?)"
        TNSQLiteManager.sharedManager.updateData(sql: sql, values: [messageHash, deviceAddress, messageStr, createDate])
    }
    
    fileprivate func getTempPubkey() -> String {
        let otherTempPubkey = TNSyncOperationManager.shared.getOherTempPubkeyFromHub(pubkey: pubkey)
        return otherTempPubkey
    }
    
    fileprivate  func createEncryptedPackageWith(packageBody: [String: Any], tempKey: String) {
        let json =  TNChatHelper.getJSONStringFrom(jsonObject: packageBody)
        let encryptedStr = TNSyncOperationManager.shared.createEncryptedPackage(json: json, pubkey: tempKey)
        let jsonData: Data = encryptedStr.data(using: .utf8)!
        let encryptedObj = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        var objDeviceMessage = ["encrypted_package": encryptedObj!, "to": deviceAddress, "pubkey": TNGlobalHelper.shared.ecdsaPubkey]
        let messageStr = TNChatHelper.getJSONStringFrom(jsonObject: objDeviceMessage)
        let signature = TNSyncOperationManager.shared.getDeviceMessageHashToSign(unit: messageStr)
        objDeviceMessage["signature"] = signature
        TNSyncOperationManager.shared.sendDeviceMessageSignature(objDeviceMessage: objDeviceMessage)
    }
}
