//
//  TNContactAddressCell.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/12.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNContactAddressCell: UITableViewCell, RegisterCellFromNib {

    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if IS_iphone5 {
            detailLabel.font = UIFont.systemFont(ofSize: 13.0)
        }
    }
    
}
