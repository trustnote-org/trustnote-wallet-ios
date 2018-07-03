//
//  TNMessageModel.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/15.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

enum TNMessageType: String {
    case pairing = "pairing"
    case text    = "text"
    case remove  = "removed_paired_device"
}

enum TNMessageSenderType {
    case oneself
    case contact
}

struct TNChatMessageModel {
    // 是否显示时间
    var isShowTime = false
    // 消息时间
    var messageTime: String?
    // 显示时间
    var showTime: String = ""
    // 文本消息内容
    var messageText = ""
    // 消息类型
    var messeageType: TNMessageType  = .text
    // 消息发送者
    var senderType: TNMessageSenderType = .oneself
}

struct TNCorrespondentDevice {
    var deviceAddress = ""
    var name = ""
    var pubkey = ""
    var hub = ""
    var is_confirmed = false
    var unreadCount = 0
}
