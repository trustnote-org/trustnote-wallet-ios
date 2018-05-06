//
//  TNDebugLogManager.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/12.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

class TNDebugLogManager: NSObject {
    
    static func debugLog(item: Any) {
        
        #if DEBUG
            print(item)
        #else
            
        #endif
    }
}
