//
//  TNAddContactsController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/14.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNAddContactsController: TNNavigationController {
    
    private let textLabel = UILabel().then {
        $0.textColor = kTitleTextColor
        $0.font = kTitleFont
        $0.text = "Add Contacts".localized
    }
    
    private let addBtn = TNButton().then {
        $0.setBackgroundImage(UIImage.creatImageWithColor(color: kGlobalColor, viewSize: CGSize(width:  kScreenW, height: 48)), for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.setTitle("Add".localized, for: .normal)
        $0.titleLabel?.font = kButtonFont
        $0.isEnabled = false
        $0.alpha = 0.3
        $0.addTarget(self, action: #selector(TNAddContactsController.addContacts), for: .touchUpInside)
    }
    
    fileprivate lazy var addContactsView: TNAddContactsView = {[unowned self] in
        let addContactsView = TNAddContactsView.addContactsView()
        addContactsView.delegate = self
        return addContactsView
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        seupUI()
    }
}

extension TNAddContactsController {
    
    @objc fileprivate func addContacts() {
        
        let code = addContactsView.inputTextView.text!
        guard verifyDeviceCode(str: code) else {
            addContactsView.warningView.isHidden = false
            addContactsView.warningLabel.text = "Incorrect code".localized
            return
        }
        
        let pubkey =  code.components(separatedBy: "@").first
        guard pubkey != TNGlobalHelper.shared.ecdsaPubkey else {
            self.addContactsView.warningView.isHidden = false
            self.addContactsView.warningLabel.text = "you can’t add your self ad friend".localized
            return
        }
        self.sendRequest(paireCode: code)
    }
    
    func sendRequest(paireCode: String) {
        let addHelper = TNChatHelper()
        addHelper.paireCode = paireCode
        addHelper.addContactOperation()
    }
    
    func verifyDeviceCode(str: String) -> Bool {
//        let regex = "/^([\\w\\/+]{44})@([\\w.:\\/-]+)#([\\w\\/+-]+)$/"
//        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
//        let isValid = predicate.evaluate(with: str)
        if str.contains("@") && str.contains("#") {
            let frontStr = str.components(separatedBy: "@").first
            if frontStr?.length == 44 {
                 return true
            }
        }
        return false
    }
}

extension TNAddContactsController: TNAddContactsViewDelegate {
    
    func didClickedScanButton() {
        let scan = TNScanViewController()
        scan.isPush = false
        scan.scanningCompletionBlock = {[unowned self] result in
            if result.contains(TNScanPrefix) {
                self.addContactsView.inputTextView.text = result.replacingOccurrences(of: TNScanPrefix, with: "")
            } else {
                self.addContactsView.inputTextView.text = result
            }
            self.textDidChanged()
        }
        navigationController?.present(scan, animated: true, completion: nil)
    }
    
    func didClickedClearButton() {
        addBtn.isEnabled = false
        addBtn.alpha = 0.3
    }
    
    func textDidChanged() {
        if (addContactsView.inputTextView.text?.isEmpty)! {
            addBtn.isEnabled = false
            addBtn.alpha = 0.3
        } else {
            addBtn.isEnabled = true
            addBtn.alpha = 1.0
        }
    }
}

extension TNAddContactsController {
    
    fileprivate func seupUI() {
        view.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kLeftMargin)
            make.top.equalTo(navigationBar.snp.bottom).offset(kTitleTopMargin)
        }
        
        view.addSubview(addContactsView)
        addContactsView.snp.makeConstraints { (make) in
            make.top.equalTo(textLabel.snp.bottom).offset(32)
            make.left.right.equalToSuperview()
            make.height.equalTo(200)
        }
        
        view.addSubview(addBtn)
        addBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kLeftMargin)
            make.centerX.equalToSuperview()
            make.height.equalTo(kButtonheight)
            make.bottom.equalToSuperview().offset(-(CGFloat(kLeftMargin) + kSafeAreaBottomH))
        }
    }
}
