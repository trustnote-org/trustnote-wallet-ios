//
//  TNEvaluateScriptManager.swift
//  TrustNote
//
//  Created by zengahilong on 2018/4/16.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import WebKit
import UIKit
import SwiftyJSON

final class TNEvaluateScriptManager {
    

    let webView = WKWebView()
    
    class var sharedInstance: TNEvaluateScriptManager {
        
        struct Static {
            static let instance: TNEvaluateScriptManager = TNEvaluateScriptManager()
        }
        return Static.instance
    }
    
    public static func loadJsFile(fileName: String) -> String {
        
        let path = Bundle.main.path(forResource: fileName, ofType: "js")
        let jsScript = try? String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        return jsScript!
    }
    
    public func evaluatingJavaScriptString(fileString: String) {
       
        webView.evaluateJavaScript(fileString) {[unowned self] (any, _) in
            
            if TNGlobalHelper.shared.isNeedGenerateSeed {
                self.generateMnemonic()
            }
            TNGlobalHelper.shared.isComlpetion = true
            
            guard TNGlobalHelper.shared.tempDeviceKey.isEmpty else {
                TNEvaluateScriptManager.sharedInstance.generateTempPublicKey(tempPrivateKey: TNGlobalHelper.shared.tempDeviceKey)
                return
            }
            self.generateTempPrivateKey()
        }
    }
}

/// MAKR: javascript API
extension TNEvaluateScriptManager {
    
    /**
     * @method mnemonic
     * @for Base
     * @param {void}
     * @return {string} 12 mnemonics
     */
    public func generateMnemonic() {
        webView.evaluateJavaScript("window.Client.mnemonic()") {(any, error) in
            if let mnemonic = any {
                //let  mnemonic1 = "stone home state island dry human capable amount luxury robot protect arch"
               let  mnemonic1 = "theme wall plunge fluid circle organ gloom expire coach patient neck clip"/*"together knife slab material electric broom wagon heart harvest side copper vote"*/

                TNGlobalHelper.shared.mnemonic = mnemonic1 //as! String
                guard TNConfigFileManager.sharedInstance.isExistProfileFile() else {
                    let version = "1.0.0"
                    let timeInterval: TimeInterval = Date().timeIntervalSince1970
                    let creatOn = Int(timeInterval)
                    let profileDict: NSDictionary = ["version" : version, "creatOn" : creatOn, "xPrivKey" : "", "tempDeviceKey" : "", "prevTempDeviceKey" : "", "mnemonic" : mnemonic1, "my_device_address" : "",  "credentials" : []]
                    TNConfigFileManager.sharedInstance.saveDataToProfile(profileDict)
                    return
                }
                TNConfigFileManager.sharedInstance.updateProfile(key: "mnemonic", value: mnemonic1)
                let hub = TNWebSocketManager.sharedInstance.generateHUbAddress(isSave: true)
                TNWebSocketManager.sharedInstance.webSocketOpen(hubAddress: hub)
            }
        }
    }
    
    /**
     * @method xPrivKey
     * @for Base
     * @param {string}  助记词
     * @return {string} 私钥
     */
    public func generateRootPrivateKeyByMnemonic(mnemonic: String) {
        let js = String(format:"window.Client.xPrivKey('%@')", arguments:[mnemonic])
        webView.evaluateJavaScript(js) {[unowned self] (any, _) in
            if let xPrivKey = any {
                let notificationName = Notification.Name(rawValue: TNDidGeneratedPrivateKeyNotification)
                if xPrivKey is Int && (xPrivKey as! Int) == 0 {
                   NotificationCenter.default.post(name: notificationName, object: "0")
                } else if xPrivKey is String {
                    TNGlobalHelper.shared.tempPrivKey = xPrivKey as! String
                    if let passsword = TNGlobalHelper.shared.password {
                        let encPrivKey = AES128CBC_Unit.aes128Encrypt(TNGlobalHelper.shared.tempPrivKey, key: passsword)
                        TNGlobalHelper.shared.encryptePrivKey = encPrivKey!
                        TNConfigFileManager.sharedInstance.updateProfile(key: "xPrivKey", value: encPrivKey!)
                    }
                    self.getEcdsaPrivkey(xPrivKey: xPrivKey as! String, completed: {
                        TNHubViewModel.loginHub()
                    })
                    NotificationCenter.default.post(name: notificationName, object: "success")
                }
            }
        }
    }
    
    /**
     * 生成根公钥
     * @method xPubKey
     * @for Base
     * @param {string}  根私钥
     * @return {string} 根公钥
     */
    public func generateRootPublicKey(xPrivKey: String) {
        let js = String(format:"window.Client.xPubKey('%@')", arguments:[xPrivKey])
        webView.evaluateJavaScript(js) {(any, _) in
            if let xPubkey = any {
                TNGlobalHelper.shared.xPubkey = xPubkey as! String
            }
        }
    }
    /**
    * 生成临时私钥
    * @method genPrivKey
    * @for Base
    * @param {void}
    * @return {string} base64编码的私钥
    */
    public func generateTempPrivateKey() {
        webView.evaluateJavaScript("window.Client.genPrivKey()") {[unowned self] (any, _) in
            
            if let tempDeviceKey = any {
                TNGlobalHelper.shared.tempDeviceKey = tempDeviceKey as! String
                self.generateTempPublicKey(tempPrivateKey: tempDeviceKey as! String)
                guard TNConfigFileManager.sharedInstance.isExistProfileFile() else {
                    let version = "1.0.0"
                    let timeInterval: TimeInterval = Date().timeIntervalSince1970
                    let creatOn = Int(timeInterval)
                    let profileDict: NSDictionary = ["version" : version, "creatOn" : creatOn, "xPrivKey" : "", "tempDeviceKey" : tempDeviceKey, "prevTempDeviceKey" : "", "mnemonic" : "", "my_device_address" : "",  "credentials" : []]
                    TNConfigFileManager.sharedInstance.saveDataToProfile(profileDict)
                    return
                }
                TNConfigFileManager.sharedInstance.updateProfile(key: "tempDeviceKey", value: tempDeviceKey)
            }
        }
    }
    
    /**
     * 根据临时私钥生成临时公钥
     * @method genPubKey
     * @for Base
     * @param {string}  临时私钥
     * @return {string} 临时公钥
     */
    public func generateTempPublicKey(tempPrivateKey: String) {
        let js = String(format:"window.Client.genPubKey('%@')", arguments:[tempPrivateKey])
        webView.evaluateJavaScript(js) { (any, _) in
            TNGlobalHelper.shared.tempPublicKey = any as! String
        }
    }
    
    /**
     * 生成m/1私钥
     * @method m1PrivKey
     * @for Base
     * @param {string}  根私钥
     * @return {string} m/1私钥
     */
    public func getEcdsaPrivkey(xPrivKey: String, completed: (() -> Swift.Void)?) {
        let js = String(format:"window.Client.m1PrivKey('%@')", arguments:[xPrivKey])
        webView.evaluateJavaScript(js) {[unowned self] (any, _) in
            TNGlobalHelper.shared.ecdsaPrivkey = any as! String
            self.getEcdsaPubkey(xPrivKey: xPrivKey, path: "m/1'", completed: completed)
        }
    }
    
    /**
     * 生成ecdsa签名公钥
     * @method ecdsaPubkey
     * @for Base
     * @param {string}  钱包私钥
     * @param {string}  派生路径
     * @return {string} 签名公钥
     */
    public func getEcdsaPubkey(xPrivKey: String, path: String, completed: (() -> Swift.Void)?) {
        let js = String(format:"window.Client.ecdsaPubkey('%@', \"%@\")", arguments:[xPrivKey, path])
        webView.evaluateJavaScript(js) { (any, _) in
            if let ecdsaPubkey = any {
                TNGlobalHelper.shared.ecdsaPubkey = ecdsaPubkey as! String
                if let completed = completed {
                    completed()
                }
            }
        }
    }
    
    /**
    * 获得设备消息hash
    * @method getDeviceMessageHashToSign
    * @for Base
    * @param {string}  消息JSON字符串
    * @return {string} base64过的hash
    */
    public func getDeviceMessageHashToSign(unit: String, completed: ((String) -> Swift.Void)?) {
        let js = String(format:"window.Client.getDeviceMessageHashToSign('%@')", arguments:[unit])
        webView.evaluateJavaScript(js) {(any, _) in
            let b64_hash = any as? String
            completed!(b64_hash!)
        }
    }
    
    /**
     * 签名
     * @method sign
     * @for Base
     * @param {string}  base64编码过的hash
     * @param {string}  根私钥 or 临时私钥。
     *                  若传递根私钥，则必须传递path派生路径；
     *                  若传递临时私钥，则path需要传递字符串null；
     * @param {string}  派生路径
     * @return {string} 签名结果
     */
    public func getHubParamSign(b64_hash: String, xPrivKey: String, path: String?, completionHandler: ((String) -> Swift.Void)?) {
        
        if let path = path {
            let js = String(format:"window.Client.sign('%@', '%@', '%@')", arguments:[b64_hash, xPrivKey, path])
            webView.evaluateJavaScript(js) {(any, _) in
                completionHandler!((any as? String)!)
            }
        }
    }
    
    /**
     * 获得base64hash
     * @method getBase64Hash
     * @for Base
     * @param {string}  单元JSON字符串
     * @return {string} base64过的hash
     */
    public func getBase64Hash(_ unit: String, completionHandler: ((String) -> Swift.Void)?) {
        let js = String(format:"window.Client.getBase64Hash('%@')", arguments:[unit])
        webView.evaluateJavaScript(js) {(any, _) in
            completionHandler!(any as! String)
        }
    }
    
    /**
     * 生成钱包公钥
     * @method walletPubKey
     * @for Base
     * @param {string}  私钥
     * @param {int}     钱包index 0-
     * @return {string} 钱包公钥
     */
    public func getWalletPubkey(xPrivKey: String, num: Int, completed: (() -> Swift.Void)?) {
        let js = String(format:"window.Client.walletPubKey('%@', %d)", arguments:[xPrivKey, num])
        webView.evaluateJavaScript(js) {[unowned self] (any, error) in
           
            if let walletPubkey = any {
                TNGlobalHelper.shared.currentWallet.xPubKey = walletPubkey as! String
                self.getWalletID(walletPubKey: walletPubkey as! String, completed: completed)
            }
        }
    }
    
    /**
     * @method walletID
     * @for Base
     * @param {string}  钱包公钥
     * @return {string} 钱包ID
     */
    public func getWalletID(walletPubKey: String, completed: (() -> Swift.Void)?) {
        let js = String(format:"window.Client.walletID('%@')", arguments:[walletPubKey])
        webView.evaluateJavaScript(js) { (any, _) in
            if let walletId = any {
                TNGlobalHelper.shared.currentWallet.walletId = walletId as! String
                if let completed = completed {
                    completed()
                }
            }
        }
    }
    
    /**
     * @method deviceAddress
     * @for Base
     * @param {string}  根私钥
     * @return {string} 设备地址
     */
    public func getMyDeviceAddress(xPrivKey: String) {
        let js = String(format:"window.Client.deviceAddress('%@')", arguments:[xPrivKey])
        webView.evaluateJavaScript(js) { (any, _) in
            if let my_device_address = any {
                TNGlobalHelper.shared.my_device_address = my_device_address as! String
                TNConfigFileManager.sharedInstance.updateProfile(key: "my_device_address", value: my_device_address)
            }
        }
    }
    
    /**
     * 生成钱包的地址
     * @method walletAddress
     * @for Base
     * @param {string}  钱包公钥
     * @param {int}     收款地址为 0; 找零地址为 1;
     * @param {int}     地址index 0-
     * @return {string} 钱包地址
     */
    public func getWalletAddress(wallet_xPubKey: String, change: Int, num: Int, completionHandler: ((String) -> Swift.Void)?) {
        let js = String(format:"window.Client.walletAddress('%@', %d, %d)", arguments:[wallet_xPubKey, change, num])
        webView.evaluateJavaScript(js) {(any, _) in
            completionHandler!(any as! String)
        }
    }
    
    /**
     * 生成钱包地址对应的公钥
     * @method walletAddress
     * @for Base
     * @param {string}  钱包公钥
     * @param {int}     收款地址为 0; 找零地址为 1;
     * @param {int}     地址index 0-
     * @return {string} 钱包地址对应的公钥
     */
    public func getWalletAddressPubkey(wallet_xPubKey: String, change: Int, num: Int, completionHandler: ((String) -> Swift.Void)?) {
        let js = String(format:"window.Client.walletAddressPubkey('%@', %d, %d)", arguments:[wallet_xPubKey, change, num])
        webView.evaluateJavaScript(js) {(any, _) in
             completionHandler!(any as! String)
        }
    }
    
    /**
     * 生成随机字节数
     * @method randomBytes
     * @for Base
     * @param {int}     字节数
     * @return {string} 随机数的base64
     */
    public func generateRandomBytes(num: Int, completionHandler: ((String) -> Swift.Void)?) {
         let js = String(format:"window.Client.randomBytes(%d)", arguments:[num])
        webView.evaluateJavaScript(js) {(any, _) in
            completionHandler!(any as! String)
        }
    }
}

extension TNEvaluateScriptManager {
    
    public func getParamsSignForLoginHub(unit: String, completionHandler: ((String) -> Swift.Void)?) {
        
        getDeviceMessageHashToSign(unit: unit) {[unowned self] (b64_hash) in
             let signHash = b64_hash
             self.getHubParamSign(b64_hash: signHash, xPrivKey: TNGlobalHelper.shared.ecdsaPrivkey, path: "null", completionHandler: completionHandler)
        }
    }
    
    public func getParamsSignForSendingTempPubkey(unit: String, completionHandler: ((String) -> Swift.Void)?) {
        getDeviceMessageHashToSign(unit: unit) {[unowned self] (b64_hash) in
            let signHash = b64_hash
            self.getHubParamSign(b64_hash: signHash, xPrivKey: TNGlobalHelper.shared.ecdsaPrivkey, path: "null", completionHandler: completionHandler)
        }
    }
    
    public func updateTempPrivKeyAndTempPubKey(completionHandler: (() -> Void)?) {
        webView.evaluateJavaScript("window.Client.genPrivKey()") {[unowned self] (any, _) in
            if let tempDeviceKey = any {
                TNGlobalHelper.shared.tempDeviceKey = tempDeviceKey as! String
                let js = String(format:"window.Client.genPubKey('%@')", arguments:[TNGlobalHelper.shared.tempDeviceKey])
                self.webView.evaluateJavaScript(js) {(any, _) in
                   TNGlobalHelper.shared.tempPublicKey = any as! String
                    completionHandler!()
                }
            }
        }
    }
}
