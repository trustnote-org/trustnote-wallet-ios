//
//  TNPasswordSecurityView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/8.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

enum TNSecurityLevel {
    case weak
    case middle
    case strong
}

class TNPasswordSecurityView: UIView {
   
    @IBOutlet weak var weakView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var strongView: UIView!
    @IBOutlet weak var weakLabel: UILabel!
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var strongLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    
    var level: TNSecurityLevel = .weak {
        didSet {
            switch level {
            case .weak:
                middleView.backgroundColor = UIColor.hexColor(rgbValue: 0xF2F2F2)
                middleLabel.textColor = UIColor.hexColor(rgbValue: 0xdddddd)
                middleView.alpha = 1.0
                strongView.backgroundColor = UIColor.hexColor(rgbValue: 0xF2F2F2)
                strongLabel.textColor = UIColor.hexColor(rgbValue: 0xdddddd)
                strongLabel.alpha = 1.0
                iconView.isHidden = false
                descLabel.isHidden = false
            case .middle:
                middleView.backgroundColor = kGlobalColor
                middleLabel.textColor = kThemeTextColor
                middleView.alpha = 0.6
                strongView.backgroundColor = UIColor.hexColor(rgbValue: 0xF2F2F2)
                strongLabel.textColor = UIColor.hexColor(rgbValue: 0xdddddd)
                strongLabel.alpha = 1.0
                iconView.isHidden = true
                descLabel.isHidden = true
            case .strong:
                middleView.backgroundColor = kGlobalColor
                middleLabel.textColor = kThemeTextColor
                middleView.alpha = 0.6
                strongView.backgroundColor = kGlobalColor
                strongLabel.textColor = kThemeTextColor
                strongLabel.alpha = 0.9
                iconView.isHidden = true
                descLabel.isHidden = true
            }
//            weakView.backgroundColor = kGlobalColor
//            weakLabel.textColor = kThemeTextColor
//            weakLabel.alpha = 0.3
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        descLabel.text = NSLocalizedString("Password.passwordSecurity", comment: "")
        weakLabel.text = NSLocalizedString("Password.weakLevel", comment: "")
        middleLabel.text = NSLocalizedString("Password.middleLevel", comment: "")
        strongLabel.text = NSLocalizedString("Password.strongLevel", comment: "")
    }

}

extension TNPasswordSecurityView: TNNibLoadable {
    
    class func passwordSecurityView() -> TNPasswordSecurityView {
        
        return TNPasswordSecurityView.loadViewFromNib()
    }
}
