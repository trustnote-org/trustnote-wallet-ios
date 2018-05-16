//
//  String+Encryption.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/14.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
//import CryptoSwift

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

//extension String {
//
//    static func Endcode_AES_ECB(strToEncode: String) -> String {
//
//        let ps = strToEncode.dataUsingEncoding(NSUTF8StringEncoding)
//
//        var encrypted: [UInt8] = []
//
//        let key: [UInt8] = ("YourKey".dataUsingEncoding(NSUTF8StringEncoding)?.arrayOfBytes())!
//        let iv: [UInt8] = []
//
//        do {
//            encrypted = try AES(key: key, iv: iv, blockMode: .ECB).encrypt((ps?.arrayOfBytes())!, padding: PKCS7())
//        } catch AES.Error.BlockSizeExceeded {
//            // block size exceeded
//        } catch {
//            // some error
//        let encoded = NSData.init(bytes: encrypted)
//        //加密结果要用Base64转码
//        return encoded.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
//    }
//
//
//    //AES-ECB128解密
//    static func Decode_AES_ECB(strToDecode:String) -> String {
//        //decode base64
//        let data = NSData(base64EncodedString: strToDecode, options: NSDataBase64DecodingOptions.init(rawValue: 0))
//
//        let encrypted = data!.arrayOfBytes()
//
//
//
//        var decrypted: [UInt8] = []
//
//        let key: [UInt8] = ("YourKey".dataUsingEncoding(NSUTF8StringEncoding)?.arrayOfBytes())!
//        let iv: [UInt8] = []
//
//        do {
//            decrypted = try AES(key: key, iv: iv, blockMode: .ECB).decrypt(encrypted, padding: PKCS7())
//        } catch AES.Error.BlockSizeExceeded {
//            // block size exceeded
//        } catch {
//            // some error
//        }
//
//        let encoded = NSData.init(bytes: decrypted)
//        var str = ""
//        str = String(data: encoded, encoding: NSUTF8StringEncoding)!
//        return str
//     }
//
//    static func Encode_SHA1(str: String) -> String {
//
//        let data = NSData.init(bytes: (str.dataUsingEncoding(NSUTF8StringEncoding)?.arrayOfBytes())!)
//
//        var sha1 = data.sha1String()
//        return sha1
//    }
//}


