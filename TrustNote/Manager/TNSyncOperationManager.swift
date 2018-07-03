//
//  TNSyncOperationManager.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/6.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

class TNSyncOperationManager: TNJSONSerializationProtocol {
    
    static let shared = TNSyncOperationManager()
    var contactHub = ""
    var myHub = ""
    
}

/// MARK: Networking
extension TNSyncOperationManager {
    
    func getParentUnit() -> [String: Any] {
        var response: [String: Any] = [:]
        let sema = DispatchSemaphore(value: 0)
        TNHubViewModel.getParentsRequest {(result) in
            response = result
            sema.signal()
        }
        _ = sema.wait(timeout:  DispatchTime.distantFuture)
        return response
    }
    
    func postTransferUnit(objectJoint: [String: Any]) -> String {
        var response = ""
        let sema = DispatchSemaphore(value: 0)
        TNHubViewModel.transfer(objectJoint: objectJoint) { (result) in
            response = result
            sema.signal()
        }
        _ = sema.wait(timeout:  DispatchTime.distantFuture)
        return response
    }
    
    func getOherTempPubkeyFromHub(pubkey: String) -> String {
        var response = ""
        let sema = DispatchSemaphore(value: 0)
        if myHub == contactHub {
            TNHubViewModel.getOtherTempPubkey(pubkey: pubkey) { (result) in
                response = result
                sema.signal()
            }
        } else {
            TNMessageWebSocket.getOtherTempPubkey(pubkey: pubkey) { (result) in
                response = result
                sema.signal()
            }
        }
        _ = sema.wait(timeout:  DispatchTime.distantFuture)
        return response
    }
    
    func sendDeviceMessageSignature(objDeviceMessage: [String: Any]) -> String {
        var response = ""
        let sema = DispatchSemaphore(value: 0)
        if myHub == contactHub {
            TNHubViewModel.sendDeviceMessage(objDeviceMessage: objDeviceMessage) { (result) in
                response = result
                sema.signal()
            }
        } else {
            TNMessageWebSocket.sendDeliver(objDeviceMessage: objDeviceMessage) { (result) in
                response = result
                sema.signal()
            }
        }
        _ = sema.wait(timeout:  DispatchTime.distantFuture)
        return response
    }
    
    func openSocket() -> String {
        guard myHub != contactHub else {
            return "connected"
        }
        var response = ""
        let sema = DispatchSemaphore(value: 0)
        TNMessageWebSocket.shared.webSocketOpen(hub: contactHub) { (result) in
            response = result
            sema.signal()
        }
        _ = sema.wait(timeout:  DispatchTime.distantFuture)
        return response
    }
}


/// MARK: Query DB
extension TNSyncOperationManager {
    
    func queryUnusedChangeAddress(walletId: String) -> String {
        var unusedAddress = ""
        let sema = DispatchSemaphore(value: 0)
        TNSQLiteManager.sharedManager.queryUnusedChangeAddress(walletId: walletId) {(results) in
            if !results.isEmpty {
                unusedAddress = results.first!
            }
            sema.signal()
        }
        _ = sema.wait(timeout:  DispatchTime.distantFuture)
        return unusedAddress
    }
    
    func queryFundAddressByAmount(walletId: String, estimateAmount: String) -> [TNFundedAddress] {
        var fundAddress: [TNFundedAddress] = []
        let sema = DispatchSemaphore(value: 0)
        TNSQLiteManager.sharedManager.queryFundedAddresses(walletId: walletId, estimateAmount: estimateAmount) { (results) in
            fundAddress = results
            sema.signal()
        }
        _ = sema.wait(timeout:  DispatchTime.distantFuture)
        return fundAddress
    }
    
    func queryUtxoByAddress(addressList: [String], lastBallMCI: Int) -> [TNOutputObject] {
        var outputs: [TNOutputObject] = []
        let sema = DispatchSemaphore(value: 0)
        TNSQLiteManager.sharedManager.queryUtxoByAddress(addressList: addressList, lastBallMCI: lastBallMCI) { (results) in
            outputs = results
            sema.signal()
        }
        _ = sema.wait(timeout:  DispatchTime.distantFuture)
        return outputs
    }
    
    func queryTransferAddress(addressList: [String]) -> [TNWalletAddressModel] {
        var addressArr: [TNWalletAddressModel] = []
        let sema = DispatchSemaphore(value: 0)
        TNSQLiteManager.sharedManager.queryTransferAddress(addressList: addressList) { (results) in
            addressArr = results
            sema.signal()
        }
        _ = sema.wait(timeout:  DispatchTime.distantFuture)
        return addressArr
    }
    
    func queryUnusedAuthor(address: String) -> Bool {
        var isUsed = false
        let sema = DispatchSemaphore(value: 0)
        TNSQLiteManager.sharedManager.queryUnusedAuthorCount(address: address) { (result) in
            if result > 0 {
                isUsed = true
            }
            sema.signal()
        }
        _ = sema.wait(timeout:  DispatchTime.distantFuture)
        return isUsed
    }
    
    func queryCount(sql: String) -> Int {
        var count = 0
        let sema = DispatchSemaphore(value: 0)
        TNSQLiteManager.sharedManager.queryCount(sql: sql) { (result) in
            count = result
            sema.signal()
        }
        _ = sema.wait(timeout:  DispatchTime.distantFuture)
        return count
    }
}

/// MARK: JS api
extension TNSyncOperationManager {
    
    func newChangeAddress(walletId: String, pubkey: String) -> String {
        var newAddress = ""
        var count = 0
        let sql = String(format:"SELECT Count(*) FROM my_addresses WHERE wallet = '%@' AND is_change = %d", arguments: [walletId, 1])
        guard TNSQLiteManager.sharedManager.database.open() else {
            return newAddress
        }
        do {
            let set = try TNSQLiteManager.sharedManager.database.executeQuery(sql, values: [walletId])
            if set.next() {
                count = Int(set.int(forColumnIndex: 0))
            }
            
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        TNSQLiteManager.sharedManager.database.close()
        let viewModel = TNWalletViewModel()
        let sema = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            viewModel.generateWalletAddress(wallet_xPubKey: pubkey, change: true, num: count) { (result) in
                newAddress = result.walletAddress
                var addressModel = result
                addressModel.walletId = walletId
                viewModel.insertWalletAddressToDatabase(walletAddressModel: addressModel)
                sema.signal()
            }
        }
        let _ = sema.wait(timeout:  DispatchTime.distantFuture)
        return newAddress
    }
    
    func getHeadersSizeSync(unit: String) -> Int64 {
        var size: Int64 = 0
        let sema = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            TNEvaluateScriptManager.sharedInstance.getHeadersSize(units: unit) { (headerSize) in
                size = headerSize
                sema.signal()
            }
        }
        let _ = sema.wait(timeout: DispatchTime.distantFuture)
        return size
    }
    
    func getTotalPayloadSync(unit: String) -> Int64 {
        var size: Int64 = 0
        let sema = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            TNEvaluateScriptManager.sharedInstance.getTotalPayloadSize(unit: unit) { (payloadSize) in
                size = payloadSize
                sema.signal()
            }
        }
        let _ = sema.wait(timeout: DispatchTime.distantFuture)
        return size
    }
    
    func genPayloadHashSync(payload: String) -> String {
        var payloadHash = ""
        let sema = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            TNEvaluateScriptManager.sharedInstance.getBase64Hash(payload, completionHandler: { (payloadHashStr) in
                payloadHash = payloadHashStr
                sema.signal()
            })
        }
        let _ = sema.wait(timeout: DispatchTime.distantFuture)
        return payloadHash
    }
    
    func getUnitSignHashSync(unit: String) -> String {
        var unitHash = ""
        let sema = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            TNEvaluateScriptManager.sharedInstance.getUnitHashToSign(unit: unit, completionHandler: { (signHashStr) in
                unitHash = signHashStr
                sema.signal()
            })
        }
        let _ = sema.wait(timeout: DispatchTime.distantFuture)
        return unitHash
    }
    
    func getUnitHashSync(unit: String) -> String {
        var unitHash = ""
        let sema = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            TNEvaluateScriptManager.sharedInstance.getUnitHash(unit: unit, completionHandler: { (unitHashStr) in
                unitHash = unitHashStr
                sema.signal()
            })
        }
        let _ = sema.wait(timeout: DispatchTime.distantFuture)
        return unitHash
    }
    
    func getTransferSign(b64_hash: String, xPrivKey: String, path: String) -> String {
        var sign = ""
        let sema = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            TNEvaluateScriptManager.sharedInstance.transferSign(b64_hash: b64_hash, xPrivKey: xPrivKey, path: path, completionHandler: { (signStr) in
                sign = signStr
                sema.signal()
            })
        }
        let _ = sema.wait(timeout: DispatchTime.distantFuture)
        return sign
    }
    
    func getRequestParamsBase64Hash(_ request: [String : Any]) -> String {
        
        var base64 = ""
        let sema = DispatchSemaphore(value: 0)
        let unit = TNWebSocketManager.getJSONStringFrom(jsonObject: request as NSDictionary)
        DispatchQueue.main.async {
            TNEvaluateScriptManager.sharedInstance.getBase64Hash(unit) { (result) in
                base64 = result
                sema.signal()
            }
        }
        let _ = sema.wait(timeout: DispatchTime.distantFuture)
        return base64
    }
    
    func getDeviceAddress(_ pubkey: String) -> String {
        var deviceAddress = ""
        let sema = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            TNEvaluateScriptManager.sharedInstance.getContactDeviceAddress(pubkey: pubkey) { (result) in
                deviceAddress = result
                sema.signal()
            }
        }
        let _ = sema.wait(timeout: DispatchTime.distantFuture)
        return deviceAddress
    }
    
    func getMySecret() -> String {
        var mySecret = ""
        let sema = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            TNEvaluateScriptManager.sharedInstance.generateRandomBytes(num: 9) { (randomBytes) in
                mySecret = randomBytes
                sema.signal()
            }
        }
        let _ = sema.wait(timeout: DispatchTime.distantFuture)
        return mySecret
    }
    
    
    func createEncryptedPackage(json: String, pubkey: String) -> String {
        var package = ""
        let sema = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            TNEvaluateScriptManager.sharedInstance.getEncryptedPackage(json: json, pubkey: pubkey, completionHandler: { (result) in
                package = result
                sema.signal()
            })
        }
        let _ = sema.wait(timeout: DispatchTime.distantFuture)
        return package
    }
    
    func getDeviceMessageHashToSign(unit: String) -> String {
        var sign = ""
        let sema = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            TNEvaluateScriptManager.sharedInstance.getParamsSign(unit: unit, completionHandler: { (result) in
                sign = result
                sema.signal()
            })
        }
        let _ = sema.wait(timeout: DispatchTime.distantFuture)
        return sign
    }
    
    func getDecryptedPackage(json: String, privkey: String, prePrivKey: String, m1PrivKey: String) -> String {
        var package = ""
        let sema = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            TNEvaluateScriptManager.sharedInstance.decryptPackage(json: json, privkey: privkey, prePrivKey: prePrivKey, m1PrivKey: m1PrivKey, completionHandler: { (result) in
                package = result
                sema.signal()
            })
        }
        let _ = sema.wait(timeout: DispatchTime.distantFuture)
        return package
    }
}
