//
//  TNEditAddressController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/12.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNEditAddressController: TNNavigationController {
   
    var titleText: String!
    
    var addressItem: [String: String]?
    
    var editCompletionBlock: ((String, String) -> Void)!
    
    fileprivate lazy var editAddressView: TNEditAddressView = {[unowned self] in
        let editAddressView = TNEditAddressView.editAddressView()
        editAddressView.delegate = self
        return editAddressView
    }()
    
    private let textLabel = UILabel().then {
        $0.textColor = kTitleTextColor
        $0.font = kTitleFont
    }
    
    init(titleText: String, completion: @escaping (String, String) -> Void) {
        self.titleText = titleText
        self.editCompletionBlock = completion
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = titleText
        setBackButton()
        setupSubviews()
        if let addressItem = addressItem {
            editAddressView.addressTextField.text = addressItem["address"]
            editAddressView.remarkTextField.text = addressItem["remarks"]
            editAddressView.setupSaveButton(isValid: true)
        }
    }
}

extension TNEditAddressController: TNEditAddressViewProtocol {
    
    func didClickedScanButton() {
        let scan = TNScanViewController()
        scan.isPush = false
        scan.scanningCompletionBlock = {[unowned self] result in
            self.scanCompletion(resultStr: result)
        }
        navigationController?.present(scan, animated: true, completion: nil)
    }
    
    func didClickedSaveButton() {
        editCompletionBlock(editAddressView.addressTextField.text!, editAddressView.remarkTextField.text!)
        navigationController?.popViewController(animated: true)
    }

}

extension TNEditAddressController {
    
    fileprivate func scanCompletion(resultStr: String) {
        editAddressView.addressTextField.text = resultStr
        if !resultStr.isEmpty && !(editAddressView.remarkTextField.text?.isEmpty)! {
            editAddressView.setupSaveButton(isValid: true)
        }
    }
}

extension TNEditAddressController {
    
    fileprivate func setupSubviews() {
        view.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kLeftMargin)
            make.top.equalTo(navigationBar.snp.bottom).offset(kTitleTopMargin)
        }
        
        view.addSubview(editAddressView)
        editAddressView.snp.makeConstraints { (make) in
            make.top.equalTo(textLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kSafeAreaBottomH)
        }
    }
}
