//
//  TNWalletTopBar.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/16.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNWalletTopBar: UIView {
    
    typealias ClickedAddButtonBlock = () -> Void
    var clickedAddButtonBlock: ClickedAddButtonBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func didClickedAddButton(_ sender: Any) {
        if let clickedAddButtonBlock = clickedAddButtonBlock {
            clickedAddButtonBlock()
        }
    }
    
}

extension TNWalletTopBar: TNNibLoadable {
    
    class func walletTopBar() -> TNWalletTopBar {
        
        return TNWalletTopBar.loadViewFromNib()
    }
}
