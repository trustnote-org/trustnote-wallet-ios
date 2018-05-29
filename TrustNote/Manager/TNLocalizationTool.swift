//
//  TNLocalizationTool.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/28.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

class TNLocalizationTool {
    
    static let shared = TNLocalizationTool()
    
    let defaults = UserDefaults.standard
    
    var bundle: Bundle?
    
    var currentLanguage: String?
    
    func valueWithKey(key: String) -> String {
        let bundle = TNLocalizationTool.shared.bundle
        if let bundle = bundle {
            return NSLocalizedString(key, tableName: "Localizable", bundle: bundle, value: "", comment: "")
        } else {
           return NSLocalizedString(key, comment: "")
        }
    }
    
    func setLanguage(langeuage: String) {
        
        var str = langeuage
        if langeuage.isEmpty {
            
            let languages: [String] = UserDefaults.standard.object(forKey: "AppleLanguages") as! [String]
            let str2: String = languages[0]
            if ((str2 == "zh-Hans-CN") || (str2 == "zh-Hans")) {
                str = "zh-Hans"
            } else {
                str = "en"
            }
        }
        currentLanguage = str
        defaults.set(str, forKey: "langeuage")
        defaults.synchronize()
        let path = Bundle.main.path(forResource:str , ofType: "lproj")
        bundle = Bundle(path: path!)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LanguageChanged"), object: nil)
    }
}

extension String {
    var localized: String {
        return TNLocalizationTool.shared.valueWithKey(key: self)
    }
}
