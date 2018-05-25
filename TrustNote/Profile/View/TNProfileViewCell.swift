//
//  TNProfileViewCell.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/24.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNProfileViewCell: UITableViewCell, RegisterCellFromNib {

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleTextLabel: UILabel!
    
    var rowDict: [String: String]? {
        didSet {
            titleTextLabel.text = rowDict?["title"]
            iconView.image = UIImage(named: "profile_" + rowDict!["imgName"]!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
