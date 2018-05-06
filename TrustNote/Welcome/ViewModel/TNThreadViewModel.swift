//
//  TNThreadViewModel.swift
//  TrustNote
//
//  Created by zengahilong on 2018/4/22.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

struct TNThreadViewModel {
    
    public var condition = NSCondition()
    /// The longest thread blocking time
    private var totalTimeForBlockingThread: Double = 15
    
    // Blocking the current thread
    func blockedCurrentThread() {
      
        let finalDate = NSDate(timeIntervalSinceNow: totalTimeForBlockingThread)
        condition.lock()
        condition.wait(until: finalDate as Date)
        condition.unlock()
    }
    
    // Wake up the current thread
    func invokeThread() {
        condition.lock()
        condition.signal()
        condition.unlock()
    }
}
