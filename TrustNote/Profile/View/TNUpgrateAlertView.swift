//
//  TNUpgrateAlertView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/8/16.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNUpgrateAlertView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var ignoreBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    
    var ignoreActionBlock: (() -> Void)?
    
    var alertHeight: CGFloat = 95
    
    var msg: String? {
        
        didSet {
            if let msg = msg {
               msgLabel.attributedText = msgLabel.getAttributeStringWithString(msg.localized, lineSpace: 5.0)
               let msgHeight = UILabel.textSizeWithLinespace(text: msg, font: UIFont.systemFont(ofSize: 14), maxSize: CGSize(width: 218, height: CGFloat(MAXFLOAT)), lineSpace: 5.0).height
                alertHeight += msgHeight
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = "Update".localized
        ignoreBtn.setTitle("Ignore".localized, for: .normal)
        downloadBtn.setTitle("Download".localized, for: .normal)
        layer.cornerRadius = 12
    }
    
    @IBAction func dowloadAction(_ sender: Any) {
        ignoreActionBlock?()
        if UIApplication.shared.canOpenURL(URL(string: "https://trustnote.org/application.html")!) {
            UIApplication.shared.openURL(URL(string: "https://trustnote.org/application.html")!)
        }
    }
    
    @IBAction func ignoreAction(_ sender: Any) {
        ignoreActionBlock?()
    }
}

extension TNUpgrateAlertView: TNNibLoadable {
    
    static func upgrateAlertView(msg: String, ignoreActionBlock: @escaping (() -> Swift.Void)) -> TNUpgrateAlertView {
        let alertView = TNUpgrateAlertView.loadViewFromNib()
        alertView.msg = msg
        alertView.ignoreActionBlock = ignoreActionBlock
        return alertView
    }
}
