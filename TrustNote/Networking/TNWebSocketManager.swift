//
//  TNWebSocketManager.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/12.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON
import HandyJSON

class TNWebSocketManager {
    
    typealias HandleRequestMessageBlock = (Any) -> Void
    
    struct HubConnectedStatus {
        var isLogin: Bool?
    }
    
    var requestTasks: [[String: Any]] = []
    
    
    fileprivate var heartBeat: Timer!
    fileprivate let rootHubs: [String] = ["shawtest.trustnote.org", "raytest.trustnote.org"]
    
    public var socket: WebSocket!
    public var challenge: String?
    public var heatBeatTag: String?
    public var isConnected: Bool = false
    public var hubStatus: HubConnectedStatus = HubConnectedStatus(isLogin: false)
    public var tempPubkeyTimeConsume = 0
    
    public var HandleHubMessageBlock:      (([String: Any]) -> Void)?
    public var recieveTransferUnitBlock:   (([String: Any]) -> Void)?
    public var recieveTransferUpdateBlock: (() -> Void)?
    
    public var generateNewPrivkeyBlock: (() -> Void)?
    public var socketDidConnectedBlock: (() -> Void)?
    public var checkOutboxMessageBlock: (() -> Void)?
    
    class var sharedInstance: TNWebSocketManager {
        
        struct Static {
            static let instance: TNWebSocketManager = TNWebSocketManager()
        }
        return Static.instance
    }    
}

/// MARK: connect and didConnect
extension TNWebSocketManager {
    
    func webSocketOpen(hubAddress: String) {
        
        guard !hubAddress.isEmpty else {
            return
        }
        socket = WebSocket(url: NSURL(string: TNWebSocketURLScheme + hubAddress)! as URL)
        if !socket.isConnected {
            socket.delegate = self
            socket.connect()
        }
    }
    
    func webSocketClose() {
        if socket.isConnected {
            socket.disconnect()
        }
    }
    
    func generateHUbAddress(isSave: Bool) -> String {
        let md5Str = TNGlobalHelper.shared.mnemonic.md5()
        let firstChar = String(md5Str[(md5Str.startIndex)])
        let num = String.getAscii(character: firstChar)
        let index = num % UInt32(rootHubs.count)
        guard isSave else {
            return rootHubs[Int(index)]
        }
        TNConfigFileManager.sharedInstance.updateConfigFile(key: "hub", value: rootHubs[Int(index)])
        return rootHubs[Int(index)]
    }
    
    private func initHeartBeat() {
        
        heartBeat = Timer.scheduledTimer(timeInterval: 20, target: self, selector:#selector(self.sendHeartBeatRequest), userInfo: nil, repeats: true)
    }
}

extension TNWebSocketManager: WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
        
        initHeartBeat()
        isConnected = true
        socketDidConnectedBlock?()
        checkOutboxMessageBlock?()
        TNHubViewModel.getMyWitnessesList()
        if let generateNewPrivkeyBlock = generateNewPrivkeyBlock {
            generateNewPrivkeyBlock()
        }
        TNDebugLogManager.debugLog(item: "Websocket Connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
        isConnected = false
        socket.connect()
        TNDebugLogManager.debugLog(item: "websocket is disconnected: \(String(describing: error?.localizedDescription))")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        TNDebugLogManager.debugLog(item: "got some data: \(data.count)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
        TNDebugLogManager.debugLog(item: "receive---->\(text)")
        let jsonData = getDictionaryFromJSONString(jsonString: text)
        let receiveMessageStyle = jsonData.first as! String
        let handleData = jsonData.last as! [String : Any]
        switch receiveMessageStyle {
        case "justsaying":
            handleJustsayingMessage(handleData)
        case "request":
            handleRequestMessage(handleData)
        case "response":
            handleResponseMessage(handleData)
        default:
            break
        }
    }
}

/// Mark: send data packet
extension TNWebSocketManager {
    
    @objc private func sendHeartBeatRequest() {
        
        var requestDict: [String : Any] = [:]
        if let tag = heatBeatTag {
            requestDict["command"] = "heartbeat"
            requestDict["tag"] = tag
            let request: [Any] = ["request", requestDict]
            let json: JSON = JSON(request)
            TNWebSocketManager.sharedInstance.socket.write(string: "\(json)")
        }
    }
    
    func sendData(_ params: String) {
        
        TNWebSocketManager.sharedInstance.socket.write(string: params)
        TNDebugLogManager.debugLog(item:  "send---->\(params)")
    }
    
    func getDictionaryFromJSONString(jsonString: String) -> [Any] {
        
        let jsonData: Data = jsonString.data(using: .utf8)!
        let dataArr = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! Array<Any>
        if dataArr != nil {
            return dataArr!
        }
        return []
    }
}

/// MARK: Handle message style
extension TNWebSocketManager {
    
    fileprivate func handleJustsayingMessage(_ handleData: [String : Any]) {
        
        let subject = handleData["subject"] as! String
        switch subject {
        case "version":
            TNHubViewModel.sendVersionToHub()
        case "hub/challenge":
            challenge = handleData["body"] as? String
            if !TNGlobalHelper.shared.ecdsaPubkey.isEmpty {
                TNHubViewModel.loginHub()
            }
        case "hub/push_project_number":
            hubStatus.isLogin = true
            if !TNGlobalHelper.shared.tempPublicKey.isEmpty {
                TNHubViewModel.sendTempPubkeyToHub()
            }
        case "hub/message":
            HandleHubMessageBlock?(handleData["body"] as! [String : Any])
        case "joint":
            recieveTransferUnitBlock?(handleData["body"] as! [String : Any])
        case "light/have_updates":
            recieveTransferUpdateBlock?()
        default:
            break
        }
    }
    
    fileprivate func handleResponseMessage(_ handleData: [String : Any]) {
        
        if handleData.keys.contains("tag") {
            let tag = handleData["tag"] as! String
            for (index, requestTask) in requestTasks.enumerated() {
                if requestTask.keys.contains("tag") && requestTask["tag"] as! String == tag {
                    
                    let command = requestTask["command"] as! RequestCommand
                    if let response = handleData["response"] {
                        switch command {
                        case .getWitnesses, .getHistory, .tempPubkey:
                            let callBack = requestTask["callBack"] as! HandleRequestMessageBlock
                            callBack(response)
                        case .getParentsUnits:
                            let callBack = requestTask["callBack"] as! ([String: Any]) -> Void
                            callBack(response as! [String : Any])
                        case .postJoint:
                            let callBack = requestTask["callBack"] as! (String) -> Void
                            if response is String {
                                callBack(response as! String)
                            }
                        case .deviceMessageSign:
                            let callBack = requestTask["callBack"] as! ([String: Any]) -> Void
                            let resonseResult = ["accepted": response, "messageHash": requestTask["messageHash"]!] as [String : Any]
                            callBack(resonseResult)
                        case .otherTempPubkey:
                            let callBack = requestTask["callBack"] as! (String) -> Void
                            let dict = response as! [String : Any]
                            callBack(dict["temp_pubkey"] as! String)
                        case .deleteHubCache:
                            break
                        }
                    }
                    requestTasks.remove(at: index)
                    break
                }
            }
        }
    }
    
    fileprivate func handleRequestMessage(_ handleData: [String : Any]) {
        
        let command = handleData["command"] as! String
        switch command {
        case "subscribe":
            let subscribeModel = TNSubscribeModel.deserialize(from: handleData)
            heatBeatTag = subscribeModel?.tag
        default:
            break
        }
        
    }
}
