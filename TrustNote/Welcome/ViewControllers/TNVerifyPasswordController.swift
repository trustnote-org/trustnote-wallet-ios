//
//  TNVerifyPasswordController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/10.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class TNVerifyPasswordController: TNBaseViewController {
    
    let topPadding = IS_iphone5 ? (88 + kStatusbarH) : (128 + kStatusbarH)
    
    var isDismissAnimated: Bool?
    
    public var passwordAlertView = TNPasswordAlertView.loadViewFromNib()
    
    fileprivate lazy var topView: TNCreateWalletTopView = {
        let topView = TNCreateWalletTopView.loadViewFromNib()
        return topView
    }()
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = UIColor.hexColor(rgbValue: 0xD3DFF1)
    }
    
    private let textLabel = UILabel().then {
        $0.textColor = kThemeTextColor
        $0.font = UIFont.systemFont(ofSize: 16.0)
        $0.text = NSLocalizedString("The wallet has been encrypted", comment: "")
    }
    
    private let continueBtn = TNButton().then {
        $0.setTitle(NSLocalizedString("Click continue", comment: ""), for: .normal)
        $0.setTitleColor(kGlobalColor, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(TNVerifyPasswordController.handleTapGesture))
        view.addGestureRecognizer(tap)
        passwordAlertView.verifyCorrectBlock = {[unowned self] in
            if self.isDismissAnimated! {
               self.dismiss(animated: true, completion: nil)
            } else {
                TNGlobalHelper.shared.isVerifyPasswdForMain = false
                UIWindow.setWindowRootController(UIApplication.shared.keyWindow, rootVC: .main)
            }
        }
        passwordAlertView.didClickedCancelBlock = {[unowned self] in
            self.backgroundView.removeFromSuperview()
        }
        passwordAlertView.setupRadiusCorner(radius: kCornerRadius * 2)
        IQKeyboardManager.shared.enable = false
        distance = 40.0
        isNeedMove = true
    }
}

extension TNVerifyPasswordController {
    
    fileprivate func setupUI() {
        
        view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topPadding)
            make.left.right.equalToSuperview()
            make.height.equalTo(190)
        }
        layoutDynamicSubviews()
    }
    
    fileprivate func layoutDynamicSubviews() {
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        view.addSubview(passwordAlertView)
        passwordAlertView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kLeftMargin)
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(316.0)
        }
    }
}

extension TNVerifyPasswordController {
    
    @objc fileprivate func handleTapGesture() {
        layoutDynamicSubviews()
        self.passwordAlertView.passwordTextField.becomeFirstResponder()
    }
}
