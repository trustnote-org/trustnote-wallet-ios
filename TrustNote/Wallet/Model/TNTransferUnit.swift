//
//  TNTransferUnit.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/7.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import HandyJSON


struct TNTransferUnit: HandyJSON {
    var unit = ""
    var version = ""
    var alt = "1"
    var witness_list_unit = ""
    var last_ball_unit = ""
    var last_ball = ""
    var headers_commission: Int64 = 0
    var payload_commission: Int64 = 0
    var parent_units: [String]?
    var authors: [TNAuthors]?
    var messages: [TNMessages]?
    var timestamp: Int64 = 0
    var earned_headers_commission_recipients: [Any] = []
}

struct TNMessages: HandyJSON {
    var app = ""
    var payload_hash = ""
    var payload_location = ""
    var payload: TNPayload?
}

struct TNPayload: HandyJSON {
    var inputs: [TNInputs]?
    var outputs: [TNOutputs]?
}

struct TNInputs: HandyJSON {
    var unit = ""
    var message_index = 0
    var output_index = 0
}

struct TNOutputs: HandyJSON {
    var address = ""
    var amount: Int64 = 0
}

struct TNAuthors: HandyJSON {
    var address = ""
    var authentifiers: [String : Any]?
    var definition: [Any] = []
}


