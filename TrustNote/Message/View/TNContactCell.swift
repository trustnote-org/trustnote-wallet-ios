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
    
    var model: TNCorrespondentDevice? {
        didSet {
            nameLabel.text = model?.name
            markLabel.text = model?.name.substring(toIndex: 1)
            if model?.unreadCount == 0 {
                msgCountBtn.isHidden = true
            } else {
                msgCountBtn.isHidden = false
                if model!.unreadCount > 99 {
                    msgCountBtn.setTitle("...", for: .normal)
                } else {
                   msgCountBtn.setTitle(String(model!.unreadCount), for: .normal)
                }
            }
            setupLastMessage(device: model!.deviceAddress)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        markLabel.layer.cornerRadius = 20.5
        markLabel.layer.masksToBounds = true
        msgCountBtn.layer.cornerRadius = 7.5
        msgCountBtn.layer.masksToBounds = true
        msgCountBtn.setBackgroundImage(UIImage.creatImageWithColor(color: UIColor.hexColor(rgbValue: 0xFF4D46), viewSize: CGSize(width: 15, height: 15)), for: .normal)
    }
    
    fileprivate func setupLastMessage(device: String) {
        TNSQLiteManager.sharedManager.queryLastMessage(deviceAddress: device) {[unowned self] (chatModel) in
            self.messageLabel.text = chatModel.messageText
            if let time = chatModel.messageTime {
               self.dateLabel.text = TNChatDate.showListTimeFormatter(time)
            }
        }
    }
}
