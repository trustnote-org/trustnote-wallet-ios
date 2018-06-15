//
//  TNContactCell.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/14.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNContactCell: UITableViewCell, RegisterCellFromNib {

    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var msgCountBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        markLabel.layer.cornerRadius = 20.5
        markLabel.layer.masksToBounds = true
        msgCountBtn.layer.cornerRadius = 7.5
        msgCountBtn.layer.masksToBounds = true
        msgCountBtn.setBackgroundImage(UIImage.creatImageWithColor(color: UIColor.hexColor(rgbValue: 0xFF4D46), viewSize: CGSize(width: 15, height: 15)), for: .normal)
    }
}
