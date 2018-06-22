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
    
    
    struct HubConnectedStatus {
        var isLogin: Bool?
    }
    
    struct ResponseTag {
        var tempPubkeyTag: String  = ""
        var getHistoryTag: String  = ""
        var getWitnessTag: String  = ""
        var getParentsTag: String  = ""
        var getTransferTag: String = ""
        var otherTempkeyTag: String = ""
        var deviceMessageTag: String = ""
    }
    
    fileprivate var heartBeat: Timer!
    public var socket: WebSocket!
    fileprivate var disConnectCount = 0
    
    fileprivate let rootHubs: [String] = ["shawtest.trustnote.org", "raytest.trustnote.org"]
    
    public var challenge: String?
    public var tag: String?
    public var isConnected: Bool = false
    public var hubStatus: HubConnectedStatus = HubConnectedStatus(isLogin: false)
    public var responseTag = ResponseTag()
    public var tempPubkeyTimeConsume = 0
    
    public var HandleJustsayingBlock: ((Any) -> Void)?
    public var GetHistoryCompletionBlock: ((Any) -> Void)?
    public var SendTempPubkeyCompletionBlock: ((Any) -> Void)?
    public var GetWitnessCompletionBlock: ((Any) -> Void)?
    public var HandleRequestBlock: ((Any) -> Void)?
    public var GetParentsCompletionBlock: (([String: Any]) -> Void)?
    public var GettransferCompletionBlock: ((String) -> Void)?
    public var GetOtherTempPubkeyBlock: ((String) -> Void)?
    
    public var generateNewPrivkeyBlock: (() -> Void)?
    
    public var socketDidConnectedBlock: (() -> Void)?
    
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
        TNHubViewModel.getMyWitnessesList()
        if let generateNewPrivkeyBlock = generateNewPrivkeyBlock {
            generateNewPrivkeyBlock()
        }
        TNDebugLogManager.debugLog(item: "Websocket Connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
        isConnected = false
        disConnectCount += 1
        socket.connect()
        //        if (disConnectCount == 4) {
        //            let hub = TNHubViewModel().hubAddress
        //            for tempHub in rootHubs {
        //                if tempHub == hub {continue}
        //                webSocketOpen(hubAddress: tempHub)
        //                break
        //            }
        //        } else {
        //           socket.connect()
        //        }
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
        if let tag = tag {
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
    
    fileprivate func getDictionaryFromJSONString(jsonString: String) -> [Any] {
        
        let jsonData: Data = jsonString.data(using: .utf8)!
        
        let dataArr = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! Array<Any>
        if dataArr != nil {
            return dataArr!
        }
        return []
    }
}

/// MARK: Hanhle message style
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
        default:
            break
        }
    }
    
    fileprivate func handleResponseMessage(_ handleData: [String : Any]) {
        
        if handleData.keys.contains("tag") {
            let tag = handleData["tag"] as! String
            if let response = handleData["response"] {
                switch tag {
                case responseTag.tempPubkeyTag:
                    SendTempPubkeyCompletionBlock!(response)
                case responseTag.getHistoryTag:
                    GetHistoryCompletionBlock!(response)
                case responseTag.getWitnessTag:
                    GetWitnessCompletionBlock!(response)
                case responseTag.getParentsTag:
                    GetParentsCompletionBlock!(response as! [String : Any])
                case responseTag.getTransferTag:
                    if response is String {
                        if response as! String == "accepted" {
                            GettransferCompletionBlock!(response as! String)
                        }
                    }
                case responseTag.otherTempkeyTag:
                    let dict = response as! [String : Any]
                    GetOtherTempPubkeyBlock!(dict["temp_pubkey"] as! String)
                default:
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
            tag = subscribeModel?.tag
        default:
            break
        }
        
    }
}
