//
//  TNMessageWebSocket.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/23.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON

class TNMessageWebSocket {
    
    public var socket: WebSocket!
    public var isConnected: Bool = false
    var otherTempkeyTag = ""
    var deviceMessageTag = ""
    var currentHub = ""
    var socktConnected: ((String) -> Void)?
    
    public var GetOtherTempPubkeyBlock:    ((String) -> Void)?
    public var SendDeviceMessageBlock:     ((String) -> Void)?
    
    class var shared: TNMessageWebSocket {
        
        struct Static {
            static let instance: TNMessageWebSocket = TNMessageWebSocket()
        }
        return Static.instance
    }
    
    func webSocketOpen(hub: String, connectedBlock: @escaping (String) -> Void) {
        guard !hub.isEmpty else {
            return
        }
        socktConnected = connectedBlock
        if isConnected {
            if hub != currentHub {
                socket = WebSocket(url: NSURL(string: TNWebSocketURLScheme + hub)! as URL)
                currentHub = hub
            } else {
                connectedBlock("connected")
                socktConnected = nil
            }
        } else {
            socket = WebSocket(url: NSURL(string: TNWebSocketURLScheme + hub)! as URL)
            currentHub = hub
            socket.delegate = self
            socket.connect()
        }
    }
    
    func webSocketClose() {
        if socket.isConnected {
            socket.disconnect()
        }
    }
    
    func sendData(_ params: String) {
        
        TNMessageWebSocket.shared.socket.write(string: params)
        TNDebugLogManager.debugLog(item:  "send---->\(params)")
    }
    
    static func sendRequest(api: String, params: Any) {
        DispatchQueue.global().async {
            var request: [String : Any] = ["command": api]
            request["params"] = params
            let objectHash = TNSyncOperationManager.shared.getRequestParamsBase64Hash(request)
            if api == "hub/get_temp_pubkey" {
                TNMessageWebSocket.shared.otherTempkeyTag = objectHash
            } else if api == "hub/deliver" {
                TNMessageWebSocket.shared.deviceMessageTag = objectHash
            }
            let requestBody = ["command": api, "params": params, "tag": objectHash]
            let requestParams: [Any] = ["request", requestBody]
            let requestJsonStr = "\(JSON(requestParams))"
            TNMessageWebSocket.shared.sendData(requestJsonStr)
        }
    }
}

extension TNMessageWebSocket: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        
        isConnected = true
        socktConnected!("connected")
        socktConnected = nil
        TNDebugLogManager.debugLog(item: "Websocket Connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
        isConnected = false
        TNDebugLogManager.debugLog(item: "websocket is disconnected: \(String(describing: error?.localizedDescription))")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        TNDebugLogManager.debugLog(item: "got some data: \(data.count)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
        TNDebugLogManager.debugLog(item: "receive---->\(text)")
        let jsonData = TNWebSocketManager.sharedInstance.getDictionaryFromJSONString(jsonString: text)
        let receiveMessageStyle = jsonData.first as! String
        let handleData = jsonData.last as! [String : Any]
        if receiveMessageStyle == "response" {
            guard handleData.keys.contains("tag") else {return}
            let tag = handleData["tag"] as! String
            if otherTempkeyTag == tag {
                if let response = handleData["response"] {
                    let dict = response as! [String : Any]
                    GetOtherTempPubkeyBlock!(dict["temp_pubkey"] as! String)
                }
            }
            if deviceMessageTag == tag {
                if let response = handleData["response"] {
                    if response is String {
                        SendDeviceMessageBlock!(response as! String)
                    }
                }
            }
        }
    }
}

extension TNMessageWebSocket {
    
    /**
     *  Method get other temp_pubkey
     *  @param pubkey
     *  @param
     */
    static func getOtherTempPubkey(pubkey: String, completion: @escaping (String) -> Void) {
        TNMessageWebSocket.shared.GetOtherTempPubkeyBlock = completion
        TNMessageWebSocket.sendRequest(api: "hub/get_temp_pubkey", params: pubkey)
    }
    
    /**
     *  Method 'hub/deliver
     *  @param objDeviceMessage
     *  @param
     */
    static func sendDeliver(objDeviceMessage: [String: Any], completion: @escaping (String) -> Void) {
        TNMessageWebSocket.shared.SendDeviceMessageBlock = completion
        TNMessageWebSocket.sendRequest(api: "hub/deliver", params: objDeviceMessage)
    }
}
