//
//  TNProtocolFooterView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/26.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TNProtocolFooterView: UIView {

    @IBOutlet weak var circleView: UIImageView!
    
    @IBOutlet weak var protocolLabel: UILabel!
    
    @IBOutlet weak var agreeButton: UIButton!
    
    private(set) var disposeBag = DisposeBag()
    
    @IBOutlet weak var buttonTopConstraint: NSLayoutConstraint!
    var isSelected = false
    override func awakeFromNib() {
        super.awakeFromNib()
        protocolLabel.text = "Protocol.agree".localized
        agreeButton.setTitle("Confirm".localized, for: .normal)
        agreeButton.layer.cornerRadius = kCornerRadius
        agreeButton.layer.masksToBounds = true
//        if TNLocalizationTool.shared.currentLanguage == "en" {
//            buttonTopConstraint.constant = 6
//        }
        
        // Subscribe button click events
        agreeButton.rx.tap.asObservable().subscribe(onNext: { _ in
            
            UIWindow.setWindowRootController(UIApplication.shared.keyWindow, rootVC: .deviceName)
            TNConfigFileManager.sharedInstance.updateConfigFile(key: "keywindowRoot", value: 2)
            
        }).disposed(by: self.disposeBag)
    }
    
    @IBAction func didClickedCircleButton(_ sender: UIButton) {
        isSelected = !isSelected
        if isSelected {
            circleView.image = UIImage(named: "protocol_selected")
            agreeButton.isEnabled = true
            agreeButton.alpha = 1.0
        } else {
            circleView.image = UIImage(named: "protocol_normal")
            agreeButton.isEnabled = false
            agreeButton.alpha = 0.3
        }
    }
}

extension TNProtocolFooterView: TNNibLoadable {
    
    class func protocolFooterView() -> TNProtocolFooterView {
        
        return TNProtocolFooterView.loadViewFromNib()
    }
}
