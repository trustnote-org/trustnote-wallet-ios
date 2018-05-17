//
//  TNCreateWalletController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/17.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNCreateWalletController: TNNavigationController {
    
    private let titleTextLabel = UILabel().then {
        $0.text =  NSLocalizedString("Create a TTT wallet", comment: "")
        $0.textColor = UIColor.hexColor(rgbValue: 0x111111)
        $0.font = UIFont.boldSystemFont(ofSize: 24.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
