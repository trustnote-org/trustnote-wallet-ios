//
//  TNAddContactHelper.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/20.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

class TNPairingHelper {
    
    var paireCode: String?
    var hub: String?
    var pubkey = ""
    var deviceAddress = ""
    var secret: String?
    var didBecomeFriendBlock: (() -> Void)?
    
    static func getMyDeviceCode(completion: @escaping (String) -> Void) {
        TNEvaluateScriptManager.sharedInstance.generateRandomBytes(num: 9) { (randomBytes) in
            let hub = TNPairingHelper.getMyHub()
            let deviceCode = TNGlobalHelper.shared.ecdsaPubkey + "@" + hub + "#" + randomBytes
            completion(deviceCode)
        }
    }
    
    static func getMyHub() -> String {
        let config = TNConfigFileManager.sharedInstance.readConfigFile()
        let myHub = config["hub"] as! String
        return myHub
    }
    
    func addContactOperation(completion: @escaping (String) -> Void) {
        
        DispatchQueue.global().async {
            
            self.generateDeviceAddress()
            
            let sql = String(format:"SELECT Count(*) FROM correspondent_devices WHERE device_address = '%@'", arguments:[self.deviceAddress])
            let count = TNSyncOperationManager.shared.queryCount(sql: sql)
            guard count == 0 else {
                self.didBecomeFriendBlock!()
                return
            }
            self.saveMessageToDatabase()
            completion(self.deviceAddress)
            TNChatManager.sendPairingMessage(isActive: true, secret: self.secret!, pubkey: self.pubkey, hub: self.hub!)
        }
    }
    
    fileprivate func saveMessageToDatabase() {
        
        let createDate = NSDate.getCurrentFormatterTime()
      
        let insertSql = "INSERT INTO correspondent_devices (device_address, name, pubkey, hub, creation_date) VALUES(?,?,?,?,?)"
        TNSQLiteManager.sharedManager.updateData(sql: insertSql, values: [deviceAddress, "new", pubkey, hub!, createDate])
        
        TNSQLiteManager.sharedManager.updateChatMessagesTable(address: deviceAddress, message: "add contact success".localized, date: createDate, isIncoming: 0, type: TNMessageType.pairing.rawValue)
        var correspondent: TNCorrespondentDevice = TNCorrespondentDevice()
        correspondent.name = "new"
        correspondent.deviceAddress = deviceAddress
        NotificationCenter.default.post(name: Notification.Name(rawValue: TNAddContactCompletedNotification), object: correspondent)
    }
    
    fileprivate  func generateDeviceAddress() {
        let components = paireCode!.components(separatedBy: "@")
        pubkey = components.first!
        let backStr = components.last
        hub = backStr?.components(separatedBy: "#").first
        secret = backStr?.components(separatedBy: "#").last
        deviceAddress = TNSyncOperationManager.shared.getDeviceAddress(pubkey)
    }
    
}
