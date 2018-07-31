//
//  TNNoContactAddressView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/12.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNNoContactAddressView: UIView {

    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        detailLabel.text = "NoContactAddress".localized
        descLabel.text = "No address".localized
    }
    
}

extension TNNoContactAddressView: TNNibLoadable {
    
    class func noContactAddressView() -> TNNoContactAddressView {
        
        return TNNoContactAddressView.loadViewFromNib()
    }
}
