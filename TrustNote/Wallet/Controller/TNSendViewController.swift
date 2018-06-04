//
//  TNSendViewController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/4.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNSendViewController: TNNavigationController {

    var wallet: TNWalletModel!
    
    init(wallet: TNWalletModel) {
        super.init()
        self.wallet = wallet
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBackButton()
        let _ = navigationBar.setRightButtonImage(imageName: "send_scan", target: self, action: #selector(self.scanAction))
    }

}

extension TNSendViewController {
    
    @objc fileprivate func scanAction() {
        
    }
    
}
