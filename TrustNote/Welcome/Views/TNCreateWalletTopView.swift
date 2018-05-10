//
//  TNCreateWalletTopView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/29.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNCreateWalletTopView: UIView {

    @IBOutlet weak var sloganLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sloganLable.font = UIFont(name: "PingFangSC-Medium", size: 22)
        sloganLable.textColor = kGlobalColor
        sloganLable.text = NSLocalizedString("Create.slogan", comment: "")
    }

}

extension TNCreateWalletTopView: TNNibLoadable {
    
    class func createWalletTopView() -> TNCreateWalletTopView {
        
        return TNCreateWalletTopView.loadViewFromNib()
    }
}
