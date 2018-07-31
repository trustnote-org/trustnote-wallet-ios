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
    
    var requestTasks: [[String: Any]] = []
    
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
    
    static func sendRequest(api: String, params: Any, command: RequestCommand, blockDict: [String: Any]) {
        DispatchQueue.global().async {
            var request: [String : Any] = ["command": api]
            request["params"] = params
            let objectHash = TNSyncOperationManager.shared.getRequestParamsBase64Hash(request)
            var requestTask: [String: Any] = blockDict
            requestTask["command"] = command
            requestTask["tag"] = objectHash
            TNMessageWebSocket.shared.requestTasks.append(requestTask)
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
        socktConnected?("connected")
        socktConnected = nil
        TNDebugLogManager.debugLog(item: "messageWebsocket Connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
        isConnected = false
        TNDebugLogManager.debugLog(item: "messageWebsocket is disconnected: \(String(describing: error?.localizedDescription))")
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
            
            for (index, requestTask) in requestTasks.enumerated() {
                
                if requestTask.keys.contains("tag") && requestTask["tag"] as! String == tag {
                    if let response = handleData["response"] {
                        let command = requestTask["command"] as! RequestCommand
                        //let callBack = requestTask["callBack"] as! (String) -> Void
                        if command == .otherTempPubkey {
                            let callBack = requestTask["callBack"] as! (String) -> Void
                            let dict = response as! [String : Any]
                            if dict.keys.contains("temp_pubkey") {
                               callBack(dict["temp_pubkey"] as! String)
                            } else {
                                callBack("")
                            }
                        } else if command == .deviceMessageSign {
                            let callBack = requestTask["callBack"] as! ([String: Any]) -> Void
                            //callBack(response as! String)
                            let resonseResult = ["accepted": response, "messageHash": requestTask["messageHash"]!] as [String : Any]
                            callBack(resonseResult)
                        }
                    }
                }
                requestTasks.remove(at: index)
                break
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
        TNMessageWebSocket.sendRequest(api: "hub/get_temp_pubkey", params: pubkey, command: .otherTempPubkey, blockDict: ["callBack": completion])
    }
    
    /**
     *  Method 'hub/deliver
     *  @param objDeviceMessage
     *  @param
     */
    static func sendDeliver(objDeviceMessage: [String: Any], messageHash: String, completion: @escaping ([String: Any]) -> Void) {
        TNMessageWebSocket.sendRequest(api: "hub/deliver", params: objDeviceMessage, command: .deviceMessageSign, blockDict: ["callBack": completion, "messageHash": messageHash])
    }
}
