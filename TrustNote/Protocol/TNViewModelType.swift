//
//  TNViewModelType.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/4.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

protocol TNViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
