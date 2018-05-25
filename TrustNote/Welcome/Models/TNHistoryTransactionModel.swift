//
//  TNHistoryTransactionModel.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/24.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import HandyJSON

struct TNHistoryTransactionModel: HandyJSON {
    
    var unstable_mc_joints: [TNWetnessJoinsModel]?
    var witness_change_and_definition_joints: [TNWetnessJoinsModel]?
    var joints: [TNWetnessJoinsModel]?
    var proofchain_balls: [TNProofchainBallModel]?
}

struct TNWetnessJoinsModel: HandyJSON {
    var unit: TNUnitModel?
    var ball = ""
    var skiplist_units: [String]?
}

struct TNUnitModel: HandyJSON {
    var unit = ""
    var version = ""
    var alt = ""
    var witness_list_unit = ""
    var last_ball_unit = ""
    var last_ball = ""
    var content_hash = ""
    var headers_commission = 0
    var payload_commission = 0
    var main_chain_index = ""
    var timestamp = ""
    var witnesses: [String]?
    var earned_headers_commission_recipients: [TNEarnedHeadModel]?
    var parent_units: [String]?
    var authors: [TNAuthorModel]?
    var messages: [TNMessageModel]?
}

struct TNAuthorModel: HandyJSON {
    var address = ""
    var authentifiers: [String : Any]?
    var definition = ""
}

struct TNMessageModel: HandyJSON {
    var app = ""
    var payload_hash = ""
    var payload_location = ""
    var payload: TNPayloadModel?
    var payload_uri_hash: String? = nil
    var payload_uri: String? = nil
}

struct TNPayloadModel: HandyJSON {
    var inputs: [TNInputModel]?
    var outputs: [TNOutputModel]?
    var asset: String?
}

struct TNInputModel: HandyJSON {
    var unit = ""
    var message_index = ""
    var output_index = ""
    var type = ""
    var serial_number = 0
    var amount = ""
    var address = ""
}

struct TNOutputModel: HandyJSON {
    var address = ""
    var amount = ""
    var denomination: Int?
}

struct TNEarnedHeadModel: HandyJSON {
    var address = ""
    var earned_headers_commission_share = 0
}

struct TNProofchainBallModel: HandyJSON {
    var unit = ""
    var ball = ""
    var parent_balls: [String]?
    var skiplist_balls: [String]?
}
