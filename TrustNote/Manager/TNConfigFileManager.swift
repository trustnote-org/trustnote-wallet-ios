//
//  TNConfigFileManager.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/14.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

final class TNConfigFileManager {
    
    //fileprivate let rootHubs: [String] = ["shawtest.trustnote.org", "raytest.trustnote.org"]
    
    class var sharedInstance: TNConfigFileManager {
        
        struct Static {
            static let instance: TNConfigFileManager = TNConfigFileManager()
        }
        return Static.instance
    }
    
    lazy var fileDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.last! as NSURL
    }()
    
    fileprivate func isExistPlistFile(fileName: String) -> Bool {
        let profileFilePath: URL = self.fileDocumentsDirectory.appendingPathComponent("/" + fileName + ".plist")!
        let exist = FileManager.default.fileExists(atPath: profileFilePath.path)
        return exist
    }
    
    fileprivate func readPlistFile(fileName: String) -> NSDictionary {
        
        let filePath: URL = self.fileDocumentsDirectory.appendingPathComponent("/" + fileName + ".plist")!
        let exist = FileManager.default.fileExists(atPath: filePath.path)
        guard exist else {
            return [:]
        }
       return NSDictionary(contentsOf: filePath)!
    }
    
    fileprivate func updatePlistFile(key: String, value: Any, fileName: String) {
        let defaultPlist = readPlistFile(fileName: fileName) as! NSMutableDictionary
        for (resultKey, _) in defaultPlist {
            if key.isEqual(resultKey) {
                defaultPlist.setValue(value, forKey: key)
                let filePath: URL = self.fileDocumentsDirectory.appendingPathComponent("/" + fileName + ".plist")!
                if #available(iOS 11.0, *) {
                    try? defaultPlist.write(to: filePath)
                } else {
                    defaultPlist.write(to: filePath, atomically: true)
                }
            }
        }
    }
    
    fileprivate func saveDataToPlist(_ data: NSDictionary, fileName: String) {
        let filePath: URL = self.fileDocumentsDirectory.appendingPathComponent("/" + fileName + ".plist")!
        if #available(iOS 11.0, *) {
            try? data.write(to: filePath)
        } else {
            data.write(to: filePath, atomically: true)
        }
    }
}

extension TNConfigFileManager {
    
    // get current device name
    private func getCurrentDeviceName() -> String {
        return UIDevice.current.name
    }
    // get hub address
    //    private func getHubConnectedAddress() -> String {
    //        let randomIndex = Int.random(rootHubs.count)
    //        return rootHubs[randomIndex]
    //    }
    
    func configGlobalFile() {
        
        TNDebugLogManager.debugLog(item: NSHomeDirectory())
        guard !isExistPlistFile(fileName: "config") else {
            return
        }
        let defaultConfig: [String : Any] = [
            "limits" : ["totalCosigners" : 6],
            "hub" : "",
            "deviceName" : getCurrentDeviceName(),
            "wallet" : ["requiredCosigners": 2,
                        "totalCosigners": 3,
                        "spendUnconfirmed": false,
                        "reconnectDelay": 5000,
                        "idleDurationMin": 4,
                        "settings" : ["unitName" : "MN",
                                      "unitValue" : 1000000,
                                      "unitDecimals" : 6,
                                      "unitCode" : "mega",
                                      "bbUnitName" : "blacknotes",
                                      "bbUnitValue" : 1,
                                      "bbUnitDecimals" : 0,
                                      "bbUnitCode" : "one",
                                      "alternativeName" : "US Dollar",
                                      "alternativeIsoCode" : "USD"]
            ],
            "rates" : ["url" : "https://insight.bitpay.com:443/api/rates"],
            "autoUpdateWitnessesList" : true,
            "keywindowRoot": 1
        ]
        let defaultConfigDict: NSDictionary = defaultConfig as NSDictionary
        saveDataToPlist(defaultConfigDict, fileName: "config")
    }
    
    func updateConfigFile(key: String, value: Any) {
        updatePlistFile(key: key, value: value, fileName: "config")
    }
    
    func readConfigFile() -> NSDictionary {
        return readPlistFile(fileName: "config")
    }
}

extension TNConfigFileManager {
    func isExistProfileFile() -> Bool {
        return isExistPlistFile(fileName: "profile")
    }
    
    func readProfileFile() -> NSDictionary {
        return readPlistFile(fileName: "profile")
    }
    
    func readWalletCredentials() -> [[String: Any]] {
        let profile = readProfileFile()
        let credentials = profile["credentials"]
        return credentials as! [[String : Any]]
    }
    
    func saveDataToProfile(_ data: NSDictionary) {
        saveDataToPlist(data, fileName: "profile")
    }
    
    func updateProfile(key: String, value: Any) {
        updatePlistFile(key: key, value: value, fileName: "profile")
    }
}

extension TNConfigFileManager {
    func isExistAddressFile() -> Bool {
        return isExistPlistFile(fileName: "address")
    }
    
    func readAddressFile() -> NSDictionary {
        return readPlistFile(fileName: "address")
    }
    
    func saveDataToAddress(_ data: NSDictionary) {
        saveDataToPlist(data, fileName: "address")
    }
    
    func updateAddress(key: String, value: Any) {
        updatePlistFile(key: key, value: value, fileName: "address")
    }
}

public extension Int {
    
    public static func random(lower: Int = 0, _ upper: Int = Int.max) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower)))
    }
}


