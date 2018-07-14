//
//  TNScanErrorController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/7/12.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNScanErrorController: TNNavigationController {
    
    let contentlabel = UILabel().then {
        $0.textColor = kThemeTextColor
        $0.font = UIFont(name: "PingFangSC-Light", size: 14)
        $0.numberOfLines = 0
    }
    
    init(content: String) {
        super.init()
        self.contentlabel.text = content
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.titleText = "扫描结果"
        setBackButton()
        view.addSubview(contentlabel)
        contentlabel.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom).offset(kLeftMargin)
            make.left.equalToSuperview().offset(kLeftMargin)
            make.centerX.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = kBackgroundColor
        var  navigationArray = navigationController?.viewControllers
        if navigationArray?.count == 3 {
            for (index, vc) in navigationArray!.enumerated() {
                if vc.isKind(of: TNScanViewController.self) {
                    navigationArray?.remove(at: index)
                }
            }
            navigationController?.viewControllers = navigationArray!
        }
    }
}
