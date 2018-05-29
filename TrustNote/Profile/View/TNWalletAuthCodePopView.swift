//
//  TNWalletAuthCodePopView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/25.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNWalletAuthCodePopView: UIView {

    var dimissBlock: ClickedDismissButtonBlock?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pubkeyLabel: UILabel!
    @IBOutlet weak var codeImageView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        layer.cornerRadius = 2 * kCornerRadius
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 20.0
    }
    
    @IBAction func dismissPopView(_ sender: Any) {
        dimissBlock?()
    }
    
}

extension TNWalletAuthCodePopView: TNNibLoadable {
    
    class func walletAuthCodePopView() -> TNWalletAuthCodePopView {
        
        return TNWalletAuthCodePopView.loadViewFromNib()
    }
}
