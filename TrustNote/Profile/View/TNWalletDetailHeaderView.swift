//
//  TNWalletDetailHeaderView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/25.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNWalletDetailHeaderView: UIView {
    
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var assertLabel: UILabel!
    @IBOutlet weak var decimalLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var walletModel: TNWalletModel? {
        didSet {
            walletNameLabel.text = walletModel?.walletName
            let length = walletModel?.balance.length
            assertLabel.text = walletModel?.balance.substring(toIndex: length! - TNGlobalHelper.shared.unitDecimals)
            decimalLabel.text = walletModel?.balance.substring(fromIndex: length! - TNGlobalHelper.shared.unitDecimals)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension TNWalletDetailHeaderView: TNNibLoadable {
    
    class func walletDetailHeaderView() -> TNWalletDetailHeaderView {
        
        return TNWalletDetailHeaderView.loadViewFromNib()
    }
}


class TNWalletDetailCell: UITableViewCell, RegisterCellFromNib {
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var detailRightMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    var cellIndex: Int! {
        didSet {
            if cellIndex == 1 {
                detailRightMarginConstraint.constant = 26
                arrowImageView.isHidden = true
                detailLabel.font = UIFont.systemFont(ofSize: 12)
            } else {
                detailRightMarginConstraint.constant = 50
                arrowImageView.isHidden = false
                detailLabel.textAlignment = .right
                detailLabel.font = UIFont.systemFont(ofSize: 14)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}
