//
//  TNTxUnits.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/3.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import RxDataSources

enum TNTransactionAction: String {
    case invalid = "INVALID"
    case sent = "SENT"
    case move = "MOVED"
    case received = "RECEIVED"
}

struct TNTxUnits {
    var plus: Int64 = 0
    var has_minus: Bool = false
    var unit: String = ""
    var level: Int32 = 0
    var is_stable: Bool = true
    var sequence: String = ""
    var address: String = ""
    var ts: Int64 = 0
    var fee: Int32 = 0
    var amount: Int64 = 0
    var to_address: String?
    var from_address: String?
    var mci: Int32 = 0
    var arrMyRecipients: [[String : Any]] = []
}

struct TNTransactionRecord {
    
    var action: TNTransactionAction?
    var amount: Int64?
    var my_address: String?
    var addressTo: String?
    var confirmations: Bool = true
    var unit: String = ""
    var fee: Int32 = 0
    var time: Int64 = 0
    var level: Int32 = 0
    var mci: Int32 = 0
    var arrPayerAddresses: [String] = []
}

struct TNTxoutputs {
    var address: String?
    var amount: Int64?
    var is_external: Bool = false
}

struct TNRecordSection {
    var items: [Item]
}

extension TNRecordSection: SectionModelType {
    
    typealias Item = TNTransactionRecord
    
    init(original: TNRecordSection, items: [Item]) {
        self = original
        self.items = items
    }
    
    init(items: [Item]?) {
        self.items = items ?? [Item]()
    }
}
