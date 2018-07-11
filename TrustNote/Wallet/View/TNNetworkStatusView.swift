//
//  TNNetworkStatusView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/7/10.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNNetworkStatusView: UIView {

    @IBOutlet weak var disconnectLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disconnectLabel.text = NSLocalizedString("Network connections are unavailable", comment: "")
    }

}

extension TNNetworkStatusView: TNNibLoadable {
    
    class func networkStatusView() -> TNNetworkStatusView {
        
        return TNNetworkStatusView.loadViewFromNib()
    }
}
