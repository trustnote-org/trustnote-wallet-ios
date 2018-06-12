//
//  TNContactAddressController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/12.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNContactAddressController: TNNavigationController {
  
    var addressList: [String] = []
    
    var selectAddressCompletion: ((String) -> Void)!
    
    fileprivate lazy var headerView: TNContactAddressHeadView = {
        let headerView = TNContactAddressHeadView.contactAddressHeadView()
        return headerView
    }()
    
    
    fileprivate lazy var noContactView: TNNoContactAddressView = {
        let noContactView = TNNoContactAddressView.noContactAddressView()
        return noContactView
    }()
    
    init(completion: @escaping (String) -> Void) {
        self.selectAddressCompletion = completion
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setupSubviews()
        if !TNConfigFileManager.sharedInstance.isExistAddressFile() {
            noContactView.isHidden = false
        } else {
            let addressDict = TNConfigFileManager.sharedInstance.readAddressFile()
            addressList = addressDict["addressList"] as! [String]
            noContactView.isHidden = addressList.isEmpty ? false : true
        }
    }

}

extension TNContactAddressController {
    
    fileprivate func setupSubviews() {
        view.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        view.addSubview(noContactView)
        noContactView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom).offset(54)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
