//
//  TNEditInfoController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/24.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNEditInfoController: TNNavigationController {
    
    fileprivate lazy var editInfoView: TNEditInfoView = {
        let editInfoView = TNEditInfoView.editInfoView()
        return editInfoView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        navigationBar.titleText = "个人信息"
        _ = navigationBar.setRightButtonTitle(title: "完成", target: self, action: #selector(self.editDone))
        view.addSubview(editInfoView)
        editInfoView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(90)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = kBackgroundColor
    }
}

extension TNEditInfoController {
    
    @objc fileprivate func editDone() {
        
        editInfoView.inputTextField.resignFirstResponder()
        
        guard (editInfoView.inputTextField.text?.isEmpty)! else {
            
            guard editInfoView.inputTextField.text!.count < maxInputCount else {
                editInfoView.warningView.isHidden = false
                return
            }
            TNConfigFileManager.sharedInstance.updateConfigFile(key: "deviceName", value: editInfoView.inputTextField.text!)
            NotificationCenter.default.post(name: Notification.Name(rawValue: TNEditInfoCompletionNotification), object: editInfoView.inputTextField.text!)
            navigationController?.popViewController(animated: true)
            return
        }
    }
}
