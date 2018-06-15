//
//  TNContactAddressHeadView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/12.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNContactAddressHeadView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    
    var addContactAddressBlock: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = "Address".localized
    }
    
    @IBAction func addAddress(_ sender: Any) {
        addContactAddressBlock?()
    }
    
}

extension TNContactAddressHeadView: TNNibLoadable {
    
    class func contactAddressHeadView() -> TNContactAddressHeadView {
        
        return TNContactAddressHeadView.loadViewFromNib()
    }
}
