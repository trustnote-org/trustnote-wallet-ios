//
//  TNProfileGeneralCell.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/28.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNProfileGeneralCell: UITableViewCell, RegisterCellFromNib {

    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var detailRightMarginConstraint: NSLayoutConstraint!
    
    var rowDict: [String: Any]? {
        didSet {
            titleTextLabel.text = rowDict?["title"] as? String
            arrowImageView.isHidden = (rowDict?["isCanSelected"] as! Bool) ? false : true
            detailLabel.text = rowDict?["detail"] as? String
            detailRightMarginConstraint.constant = (rowDict?["isCanSelected"] as! Bool) ? 50 : 26
            selectionStyle = (rowDict?["isCanSelected"] as! Bool) ? .`default` : .none
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

   
}
