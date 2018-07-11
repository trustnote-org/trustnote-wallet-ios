//
//  TNPushHelper.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/28.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

class TNPushHelper {
    
    static let shared = TNPushHelper()
    
    func setHandleHubPush() {
        setHandleHubMessage()
        setRecieveTrasferUnit()
        setRecieveTransferUpdate()
    }
    
    func setHandleHubMessage() {
        TNChatManager.recieveHubMessage()
    }
    
    func setRecieveTrasferUnit() {
        TNWebSocketManager.sharedInstance.recieveTransferUnitBlock = { body in
            let viewModel = TNHistoryRecordsViewModel()
            let unitModel = TNUnitModel.deserialize(from: body["unit"] as? [String: Any])
            var joinsModel = TNWetnessJoinsModel()
            joinsModel.unit = unitModel
            viewModel.historyTransactionModel.joints = [joinsModel]
            viewModel.processingTheAcquiredData()
        }
    }
    
    func setRecieveTransferUpdate() {
        TNWebSocketManager.sharedInstance.recieveTransferUpdateBlock = {
            let rootVC = UIApplication.shared.keyWindow?.rootViewController as? TNTabBarController
            let nav = rootVC?.viewControllers?.first as! TNBaseNavigationController
            let homeVC = nav.viewControllers.first as! TNWalletHomeController
            homeVC.syncData(false)
        }
    }
}
