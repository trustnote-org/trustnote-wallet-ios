//
//  TNTimerHelper.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/29.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

typealias ActionBlock = () -> ()

class TNTimerHelper {
   
    static let shared = TNTimerHelper()
    
    lazy var timerContainer = [String: DispatchSourceTimer]()
    
    /// GCD定时器
    func scheduledDispatchTimer(WithTimerName name: String?, timeInterval: Double, queue: DispatchQueue, repeats: Bool, action: @escaping ActionBlock) {
        
        if name == nil {
            return
        }
        
        var timer = timerContainer[name!]
        if timer == nil {
            timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
            timer?.resume()
            timerContainer[name!] = timer
        }
     
        timer?.schedule(deadline: .now(), repeating: timeInterval, leeway: DispatchTimeInterval.milliseconds(100))
        timer?.setEventHandler(handler: { [weak self] in
            action()
            if repeats == false {
                self?.cancleTimer(WithTimerName: name)
            }
        })
    }
    
    /// Cancel
    ///
    /// - Parameter name: Timer Name
    func cancleTimer(WithTimerName name: String?) {
        let timer = timerContainer[name!]
        if timer == nil {
            return
        }
        timerContainer.removeValue(forKey: name!)
        timer?.cancel()
    }
    
    
  
    /// - Returns: Whether the timer has already existed
    func isExistTimer(WithTimerName name: String?) -> Bool {
        if timerContainer[name!] != nil {
            return true
        }
        return false
    }
    
}

