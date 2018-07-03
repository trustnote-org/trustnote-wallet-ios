//
//  TNTradeDetailCell.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/23.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

enum TNTradeDetailRow: Int {
    case reciever  = 0
    case fee       = 1
    case date      = 2
    case unit      = 3
    case status    = 4
}

class TNTradeDetailCell: UITableViewCell, RegisterCellFromNib {
    
    @IBOutlet weak var statusView: UIButton!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleTextLabel: UILabel!
    var content: String? {
        didSet {
            contentLabel.text = content
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        statusView.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0)
        statusView.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
    }
}
