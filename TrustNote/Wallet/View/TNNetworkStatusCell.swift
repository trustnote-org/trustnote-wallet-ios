//
//  TNNetworkStatusCell.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/16.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNNetworkStatusCell: UITableViewCell {
    
    @IBOutlet weak var disconnectLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        disconnectLabel.text = NSLocalizedString("Network connections are unavailable", comment: "")
    }
    
}
