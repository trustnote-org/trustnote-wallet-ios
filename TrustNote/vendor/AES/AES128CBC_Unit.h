//
//  AES128CBC_Unit.h
//  TrustNote
//
//  Created by zenghailong on 2018/5/15.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AES128CBC_Unit : NSObject

+ (NSString *)AES128Encrypt:(NSString *)plainText key:(NSString *)aes_key;

+ (NSString *)AES128Decrypt:(NSString *)encryptText key:(NSString *)aes_key;
@end
