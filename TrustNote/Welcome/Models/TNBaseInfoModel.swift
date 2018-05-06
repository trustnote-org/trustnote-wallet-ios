//
//  TNBaseInfoModel.swift
//  TrustNote
//
//  Created by zengahilong on 2018/4/14.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import HandyJSON

struct TNChallengeModel: HandyJSON {
    
    var subject: String?
    var body: String?
}

struct TNSubscribeModel: HandyJSON {
    
    struct paramModel: HandyJSON{
        var subscription_id: String?
        var last_mci: String?
    }
    var command: String?
    var body: String?
    var tag: String?
    var params: paramModel?
}
