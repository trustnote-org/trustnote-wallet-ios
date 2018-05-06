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

    
    @IBOutlet weak var protocolLabel: UILabel!
    
    @IBOutlet weak var agreeButton: UIButton!
    
    private(set) var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        protocolLabel.text = NSLocalizedString("Protocol.agree", comment: "")
        agreeButton.setTitle(NSLocalizedString("Button.agree", comment: ""), for: .normal)
        agreeButton.layer.cornerRadius = agreeButton.height / 2
        agreeButton.layer.masksToBounds = true
        
        
        // Subscribe button click events
        agreeButton.rx.tap.asObservable().subscribe(onNext: { _ in
            
            UIWindow.setWindowRootController(UIApplication.shared.keyWindow, rootVC: .deviceName)
            TNConfigFileManager.sharedInstance.updateConfigFile(key: "keywindowRoot", value: 2)
            if TNGlobalHelper.shared.isComlpetion {
                TNEvaluateScriptManager.sharedInstance.generateMnemonic()
            } else {
                TNGlobalHelper.shared.isNeedGenerateSeed = true
            }
            
        }).disposed(by: self.disposeBag)
    }
}

extension TNProtocolFooterView: TNNibLoadable {
    
    class func protocolFooterView() -> TNProtocolFooterView {
        
        return TNProtocolFooterView.loadViewFromNib()
    }
}
