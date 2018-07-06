//
//  TNModifyRemarkController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/25.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNModifyRemarkController: TNNavigationController {
    
    var correspondent: TNCorrespondentDevice!
    
    let limitedInputCount = 20
    
    fileprivate lazy var editRemarkView: TNEditRemarkView = {
        let editRemarkView = TNEditRemarkView.editRemarkView()
        return editRemarkView
    }()
    
    init(correspondent: TNCorrespondentDevice) {
        super.init()
        self.correspondent = correspondent
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editRemarkView.inputTextField.text = correspondent.name
        setBackButton()
        navigationBar.titleText = "Set Alias".localized
        _ = navigationBar.setRightButtonTitle(title: "完成", target: self, action: #selector(self.editDone))
        view.addSubview(editRemarkView)
        editRemarkView.snp.makeConstraints { (make) in
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

extension TNModifyRemarkController {
    
    @objc fileprivate func editDone() {
        editRemarkView.inputTextField.resignFirstResponder()
        guard (editRemarkView.inputTextField.text?.isEmpty)! else {
            guard editRemarkView.inputTextField.text!.count <= limitedInputCount else {
                editRemarkView.warningView.isHidden = false
                return
            }
            let sql = "UPDATE correspondent_devices SET name=? WHERE device_address=?"
            TNSQLiteManager.sharedManager.updateData(sql: sql, values: [editRemarkView.inputTextField.text!, correspondent.deviceAddress])
             NotificationCenter.default.post(name: Notification.Name(rawValue: TNDidSetAliasSuccessNotification), object: ["from": correspondent.deviceAddress, "deviceName": editRemarkView.inputTextField.text!])
            navigationController?.popViewController(animated: true)
            return
        }
    }
}
