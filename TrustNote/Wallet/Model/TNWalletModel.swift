//
//  TNWalletModel.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/20.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import HandyJSON

struct TNWalletBalance {
    var walletId: String = ""
    var address: String = ""
    var asset: String? = nil
    var amount: String = ""
}

struct TNWalletAddressModel {
    
    var walletAddress: String = ""
    var walletId: String = ""
    var walletAddressPubkey: String = ""
    var is_change: Bool = false    // Is it a change in the address? default NO
    var creation_date: String?
    var definition: String = ""
    var address_index: Int = 0
}

class TNWalletModel: HandyJSON {
    
    var walletId: String = ""
    var network: String = "livenet"
    var xPubKey: String = ""
    var publicKeyRing: [Any]?
    var walletName: String = "TTT01"
    var derivationStrategy: String = "BIP44"
    var account: Int = 0
    var mnemonicHasPassphrase: Bool = false
    var m: String = "1"
    var n: String = "1"
    var creation_date: String = ""
    var isLocal = true
    var balance = "0.0000"
    
    required init() {}
}

