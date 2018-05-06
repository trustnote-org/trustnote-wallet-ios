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
        
        let configFilePath: URL = self.fileDocumentsDirectory.appendingPathComponent("/config.plist")!
        let exist = FileManager.default.fileExists(atPath: configFilePath.path)
        TNDebugLogManager.debugLog(item: NSHomeDirectory())
        guard !exist else {
            return
        }
        let  defaultConfig: [String : Any] = [
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
        if #available(iOS 11.0, *) {
            try? defaultConfigDict.write(to: configFilePath)
        } else {
            defaultConfigDict.write(to: configFilePath, atomically: true)
        }
    }
    
    func updateConfigFile(key: String, value: Any) {
        
        let defaultConfig = readConfigFile() as! NSMutableDictionary
        for (resultKey, _) in defaultConfig {
            if key.isEqual(resultKey) {
                defaultConfig.setValue(value, forKey: key)
                let configFilePath: URL = self.fileDocumentsDirectory.appendingPathComponent("/config.plist")!
                if #available(iOS 11.0, *) {
                    try? defaultConfig.write(to: configFilePath)
                } else {
                    defaultConfig.write(to: configFilePath, atomically: true)
                }
            }
        }

    }
    
    func readConfigFile() -> NSDictionary {
        
         let configFilePath: URL = self.fileDocumentsDirectory.appendingPathComponent("/config.plist")!
        let exist = FileManager.default.fileExists(atPath: configFilePath.path)
        guard exist else {
            return [:]
        }
        let defaultConfig: NSDictionary = NSDictionary(contentsOf: configFilePath)!
        return defaultConfig
    }
    
    func isExistProfileFile() -> Bool {
        let profileFilePath: URL = self.fileDocumentsDirectory.appendingPathComponent("/profile.plist")!
        let exist = FileManager.default.fileExists(atPath: profileFilePath.path)
        return exist
    }
    
    func readProfileFile() -> NSDictionary {
         let profileFilePath: URL = self.fileDocumentsDirectory.appendingPathComponent("/profile.plist")!
        let profileInfoDict: NSDictionary = NSDictionary(contentsOf: profileFilePath)!
        return profileInfoDict
    }
    
    func saveDataToProfile(_ data: NSDictionary) {
        let profilePath: URL = self.fileDocumentsDirectory.appendingPathComponent("/profile.plist")!
        if #available(iOS 11.0, *) {
            try? data.write(to: profilePath)
        } else {
            data.write(to: profilePath, atomically: true)
        }
    }
    
    func updateProfile(key: String, value: Any) {
        let defaultProfile = readProfileFile() as! NSMutableDictionary
        for (resultKey, _) in defaultProfile {
            if key.isEqual(resultKey) {
                defaultProfile.setValue(value, forKey: key)
                let configFilePath: URL = self.fileDocumentsDirectory.appendingPathComponent("/profile.plist")!
                if #available(iOS 11.0, *) {
                    try? defaultProfile.write(to: configFilePath)
                } else {
                    defaultProfile.write(to: configFilePath, atomically: true)
                }
            }
        }
    }
}

public extension Int {
    
    public static func random(lower: Int = 0, _ upper: Int = Int.max) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower)))
    }
}


