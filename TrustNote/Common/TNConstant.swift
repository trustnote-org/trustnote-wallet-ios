//
//  TNConstant.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/27.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

let TNVersion = "1.0"

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

let kTitleFont = UIFont(name: "PingFangSC-Semibold", size: 24)

let kButtonFont = UIFont.systemFont(ofSize: 18.0)

let TNWebSocketURLScheme: String = "wss://"

let TNScanPrefix = "TTT:"

let kNetworkTimeout = 30
let kTempPubkeyInterval = 3600
let kBaseOrder = 1000000.0

/// MARK:- Color
let Navigation_Bar_Color = UIColor.white
let kThemeWhiteColor = UIColor.hexColor(rgbValue: 0xFFFFFF)
let kGlobalColor = UIColor.hexColor(rgbValue: 0x0052CC)
let kThemeTextColor = UIColor.hexColor(rgbValue: 0x333333)
let kTitleTextColor = UIColor.hexColor(rgbValue: 0x111111)
let kBackgroundColor = UIColor.hexColor(rgbValue: 0xF6F7F9)
let kThemeMarkColor = UIColor.hexColor(rgbValue: 0xF6782F)
let kLineViewColor = UIColor.hexColor(rgbValue: 0xCBD5E3)
let kWarningHintColor = UIColor.hexColor(rgbValue: 0xEF2B2B)
let kAlertBackgroundColor = UIColor.hexColor(rgbValue: 0xD3DFF1, alpha: 0.8)

/// MARK: Notificaton Name
let TNDidGeneratedPrivateKeyNotification       = "TNDidGeneratePrivateKeyNotification"
let TNDidFinishedGetHistoryTransaction         = "TNDidFinishGetHistoryTransaction"
let TNDidReceiveRestoreWalletResponse          = "TNDidReceiveRestoreWalletResponse"
let TNDidFinishRecoverWalletNotification       = "TNDidFinishRecoverWalletNotification"
let TNDidFinishUpdateDatabaseNotification      = "TNDidFinishUpdateDatabaseNotification"
let TNCreateCommonWalletNotification           = "TNCreateCommonWalletNotification"
let TNCreateObserveWalletNotification          = "TNCreateObserveWalletNotification"
let TNEditInfoCompletionNotification           = "TNEditInfoCompletionNotification"
let TNModifyWalletNameNotification             = "TNModifyWalletNameNotification"
let TNDidFinishDeleteWalletNotification        = "TNDidFinishDeleteWalletNotification"
let TNDidFinishSyncClonedWalletNotify          = "TNDidFinishSyncClonedWalletNotify"
let TNTransferSendSuccessNotify                = "TNTransferSendSuccessNotify"

/// Genesis Unit
let GENESIS_UNIT = "rg1RzwKwnfRHjBojGol3gZaC5w7kR++rOR6O61JRsrQ="

/// MARK: Timer Name
let kGetHistoryTimer      = "MonitorNetworkResponse"
let kSendTempPubkeyTimer  = "SendTempPubkeyTimer"
let kScanCodeTimer        = "ScanCodeTimer"
