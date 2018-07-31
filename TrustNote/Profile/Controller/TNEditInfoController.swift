//
//  TNEditInfoController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/24.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNEditInfoController: TNNavigationController {
    
    var isEditInfo: Bool!
    
    var limitedInputCount: Int!
    
    var wallet: TNWalletModel?
    
    fileprivate lazy var editInfoView: TNEditInfoView = {
        let editInfoView = TNEditInfoView.editInfoView()
        return editInfoView
    }()
    
    init(isEditInfo: Bool) {
        super.init()
        self.isEditInfo = isEditInfo
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        navigationBar.titleText = isEditInfo ? "Personal information".localized : "Wallet name".localized
        _ = navigationBar.setRightButtonTitle(title: "Done".localized, target: self, action: #selector(self.editDone))
        limitedInputCount = isEditInfo ? 20 : 10
        editInfoView.isEditInfo = isEditInfo
        if let walletModel = wallet {
            editInfoView.inputTextField.text = walletModel.walletName
        }
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
            
            guard editInfoView.inputTextField.text!.count <= limitedInputCount else {
                editInfoView.warningView.isHidden = false
                return
            }
            if isEditInfo {
                TNConfigFileManager.sharedInstance.updateConfigFile(key: "deviceName", value: editInfoView.inputTextField.text!)
                NotificationCenter.default.post(name: Notification.Name(rawValue: TNEditInfoCompletionNotification), object: editInfoView.inputTextField.text!)
            } else {
                var credentials  = TNConfigFileManager.sharedInstance.readWalletCredentials()
                for (index, dict) in credentials.enumerated() {
                    if dict["walletId"] as? String == wallet?.walletId {
                        var newDict = dict
                        newDict["walletName"] = editInfoView.inputTextField.text!
                        credentials[index] = newDict
                        break
                    }
                }
                TNConfigFileManager.sharedInstance.updateProfile(key: "credentials", value: credentials)
                NotificationCenter.default.post(name: Notification.Name(rawValue: TNModifyWalletNameNotification), object: editInfoView.inputTextField.text!)
            }
            navigationController?.popViewController(animated: true)
            return
        }
        let hint = isEditInfo ? "设备名称不能为空" : "钱包名称不能为空"
        MBProgress_TNExtension.showViewAfterSecond(title: hint)
    }
    
}
