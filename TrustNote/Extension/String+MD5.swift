//
//  String+MD5.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/23.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

extension String {
    
    func md5() -> String {
        
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize()
        
        return String(format: hash as String)
    }
}

extension String {
    
    static func getAscii(character: String) -> UInt32 {
        var num: UInt32 = 0
        for scalar in character.unicodeScalars  {
            num = scalar.value
        }
         return num
    }
}
