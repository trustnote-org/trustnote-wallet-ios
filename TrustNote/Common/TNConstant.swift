//
//  TNConstant.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/27.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

let kScreenH = UIScreen.main.bounds.height   // screen height

let kScreenW = UIScreen.main.bounds.width    // screen width

let IS_iPhoneX = (kScreenW == 375.0 && kScreenH == 812.0 ? true : false) // is iPhoneX?

let IS_iphone5 = (kScreenW == 320.0 && kScreenH == 568.0 ? true : false)

let kStatusbarH: CGFloat = IS_iPhoneX ? 44.0 : 20.0      // status bar height

let kSafeAreaBottomH: CGFloat = IS_iPhoneX ? 34.0 : 0        // bottom  safe height

let scale = IS_iphone5 ? 0.7 : 1.0

let kLeftMargin = 26.0

let kNavBarHeight: CGFloat = IS_iPhoneX ? 84.0 : 64.0

let kCornerRadius: CGFloat = 2.0

let TNWebSocketURLScheme: String = "wss://"

let kNetworkTimeout = 30

/// MARK:- Color
let TNControllerViewBackgroundColor = UIColor.hexColor(rgbValue: 0xF5F5F5)
let Navigation_Bar_Color = UIColor.black
let kThemeWhiteColor = UIColor.hexColor(rgbValue: 0xFFFFFF)
let kGlobalColor = UIColor.hexColor(rgbValue: 0x0052CC)
let kThemeTextColor = UIColor.hexColor(rgbValue: 0x333333)

/// MARK: Notificaton Name
let TNDidGeneratedPrivateKey           = "TNDidGeneratePrivateKey"
let TNDidFinishedGetHistoryTransaction = "TNDidFinishGetHistoryTransaction"
let TNDidReceiveRestoreWalletResponse  = "TNDidReceiveRestoreWalletResponse"

/// Genesis Unit
let GENESIS_UNIT = "rg1RzwKwnfRHjBojGol3gZaC5w7kR++rOR6O61JRsrQ="
