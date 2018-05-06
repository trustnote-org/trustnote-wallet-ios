//
//  TNProtocolHeaderView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/23.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNProtocolHeaderView: UIView {

    @IBOutlet weak var protocolTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        protocolTitleLabel.text = NSLocalizedString("Terms of Use", comment: "")
    }
    
}

extension TNProtocolHeaderView: TNNibLoadable {
    
    class func protocolHeaderView() -> TNProtocolHeaderView {
        
        return TNProtocolHeaderView.loadViewFromNib()
    }
}
