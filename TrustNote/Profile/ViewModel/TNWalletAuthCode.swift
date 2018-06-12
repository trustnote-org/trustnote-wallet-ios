//
//  TNWalletAuthCode.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/25.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

struct TNWalletAuthCode {
    
    func generateWalletAuthCode(wallet: TNWalletModel) -> String {
        var content: [String: Any] = [:]
        content["type"] = "c1"
        content["name"] = wallet.walletName
        content["pub"] = wallet.xPubKey
        content["n"] = wallet.account
        content["v"] = anyIndex()
        let data : NSData! = try? JSONSerialization.data(withJSONObject: content, options: []) as NSData!
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)! as String
        return TNScanPrefix + JSONString
    }
    
    func anyIndex() -> UInt32 {
        let a: UInt32 = arc4random_uniform(9999)
        if a < 1000 {
            return anyIndex()
        }
        return a
    }
}
