//
//  TNCreateWalletTopView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/29.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNCreateWalletTopView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

extension TNCreateWalletTopView: TNNibLoadable {
    
    class func createWalletTopView() -> TNCreateWalletTopView {
        
        return TNCreateWalletTopView.loadViewFromNib()
    }
}
