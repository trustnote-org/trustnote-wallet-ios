//
//  TNCreateWalletController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/17.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON

class TNCreateWalletController: TNNavigationController {
    
    let scrollViewTopConstraint: CGFloat = 142
    
    fileprivate var isImportValid: BehaviorRelay<Bool> =  BehaviorRelay(value: false)
    fileprivate var isCompletionValid: BehaviorRelay<Bool> =  BehaviorRelay(value: false)
    
    var inputMsg: String?
    
    let startAuthAlert = TNObserveWaletAlertView.observeWaletAlertView()
    let authCompletedAlert = TNAuthDoneAlertView.authDoneAlertView()
    var authCompletedAlertView: TNCustomAlertView?
    
    private let titleTextLabel = UILabel().then {
        $0.text =  NSLocalizedString("Create a TTT wallet", comment: "")
        $0.textColor = UIColor.hexColor(rgbValue: 0x111111)
        $0.font = UIFont.boldSystemFont(ofSize: 24.0)
    }
    
    private let scrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.bounces = false
        $0.isPagingEnabled = true
        $0.contentSize = CGSize(width: 2 * kScreenW, height: 0)
    }
    
    fileprivate lazy var switchView: TNCreateWalletSwitchView = {
        let switchView = TNCreateWalletSwitchView.createWalletSwitchView()
        return switchView
    }()
    
    fileprivate lazy var commonWalletView: TNCreateCommonWalletView = {
        let commonWalletView = TNCreateCommonWalletView.createCommonWalletView()
        return commonWalletView
    }()
    
    fileprivate lazy var observeWalletView: TNCreateObserveWalletView = {
        let observeWalletView = TNCreateObserveWalletView.createObserveWalletView()
        return observeWalletView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        switchView.delegate = self
        scrollView.delegate = self
        layoutAllSubviews()
        startScanning()
        observeWalletView.clickedImportButtonBlock = {[unowned self] in
            let marginX: CGFloat = 6.0
            let marginY: CGFloat = 58.0
            let alertFrame = CGRect(x: marginX, y: marginY, width: kScreenW - 2 * marginX, height: kScreenH - 2 * marginY)
            let authAlertView = TNCustomAlertView(alert: self.startAuthAlert, alertFrame: alertFrame, isShowAnimated: true)
            self.startAuthAlert.dimissBlock = {
                authAlertView.removeFromSuperview()
            }
            /// create qrCode
            let qrInput = self.generateQRCodeInputMsg(self.inputMsg!)
            self.startAuthAlert.qrCodeImageView.image = UIImage.createHDQRImage(input: qrInput , imgSize: self.startAuthAlert.qrCodeImageView.size)
        }
        
        startAuthAlert.clickedNextButtonBlock = {[unowned self] in
            self.startAuthAlert.dimissBlock?()
            let marginX: CGFloat = 26.0
            let marginY: CGFloat = 78.0
            let alertFrame = CGRect(x: marginX, y: marginY, width: kScreenW - 2 * marginX, height: kScreenH - 2 * marginY)
            self.authCompletedAlertView = TNCustomAlertView(alert: self.authCompletedAlert, alertFrame: alertFrame, isShowAnimated: false)
            self.authCompletedAlert.dimissBlock = {
                self.authCompletedAlertView?.removeFromSuperview()
            }
            self.authCompletedAlert.backActionBlock = {
                self.navigationController?.popViewController(animated: true)
            }
        }
        isImportValid.asDriver().drive(observeWalletView.importButton.rx_validState).disposed(by: self.disposeBag)
        isCompletionValid.asDriver().drive(authCompletedAlert.doneBtn.rx_validState).disposed(by: self.disposeBag)
    }
}

extension TNCreateWalletController {
    
    fileprivate func layoutAllSubviews() {
        view.addSubview(titleTextLabel)
        titleTextLabel.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom).offset(9)
            make.left.equalToSuperview().offset(kLeftMargin)
        }
        
        view.addSubview(switchView)
        switchView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleTextLabel.snp.bottom).offset(19)
            make.height.equalTo(46)
        }
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(switchView.snp.bottom)
            make.bottom.equalToSuperview().offset(-kSafeAreaBottomH)
        }
        commonWalletView.frame = CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH - scrollViewTopConstraint - kStatusbarH)
        scrollView.addSubview(commonWalletView)
        
        observeWalletView.frame =  CGRect(x: kScreenW, y: 0, width: kScreenW, height: commonWalletView.height)
        scrollView.addSubview(observeWalletView)
        
    }
}

extension TNCreateWalletController: TNCreateWalletSwitchViewDelegate {
    
    func didClickedCommonWalletBtn() {
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func didClickedObservWalletBtn() {
        scrollView.setContentOffset(CGPoint(x: kScreenW, y: 0), animated: true)
    }
    
    fileprivate func startScanning() {
        observeWalletView.clickedScanButtonBlock = {[unowned self] in
            let scanningVC = TNScanViewController()
            self.navigationController?.pushViewController(scanningVC, animated: true)
            scanningVC.scanningCompletionBlock = { (result) in
                self.observeWalletView.identCodeLabel.text = result
                self.observeWalletView.identCodeLabel.sizeToFit()
                self.observeWalletView.identCodeLabel.textColor = kThemeTextColor
                let codeSize = self.observeWalletView.identCodeLabel.textSize(text: result, font: self.observeWalletView.identCodeLabel.font, maxSize: CGSize(width: kScreenW - CGFloat(2 * kLeftMargin), height: CGFloat(MAXFLOAT)))
                self.observeWalletView.lineViewTopMarginConstraint.constant = codeSize.height + 30
                let isValid = self.verifyCode(result)
                self.isImportValid.accept(isValid)
                self.observeWalletView.invalidLabel.isHidden = isValid ? true : false
                self.observeWalletView.invalidImgview.isHidden = isValid ? true : false
                self.inputMsg = result
            }
        }
        
        authCompletedAlert.clickedScanButtonBlock = {[unowned self] in
            let scanningVC = TNScanViewController()
            self.authCompletedAlert.dimissBlock?()
            self.navigationController?.pushViewController(scanningVC, animated: true)
            scanningVC.scanningCompletionBlock = { (result) in
                let keyWindow = UIApplication.shared.keyWindow
                keyWindow?.addSubview(self.authCompletedAlertView!)
                self.authCompletedAlert.placeHolderLabel.text = result
                self.authCompletedAlert.placeHolderLabel.sizeToFit()
                self.authCompletedAlert.placeHolderLabel.textColor = kThemeTextColor
                let codeSize = self.authCompletedAlert.placeHolderLabel.textSize(text: result, font: self.authCompletedAlert.placeHolderLabel.font, maxSize: CGSize(width: kScreenW - CGFloat(2 * (kLeftMargin + 30)), height: CGFloat(MAXFLOAT)))
                self.authCompletedAlert.lineTopMarginConstraint.constant = codeSize.height + 30
                // TODO
                self.isCompletionValid.accept(true)
            }
        }
    }
}

extension TNCreateWalletController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else {
            return
        }
        if scrollView.contentOffset.x > kScreenW * 0.5 {
            switchView.shouldSelelctCommonWalletButton(isSelected: false)
        } else {
            switchView.shouldSelelctCommonWalletButton(isSelected: true)
        }
    }
}

extension TNCreateWalletController {
    
    fileprivate func verifyCode(_ identCode: String) -> Bool {
        
        guard identCode.hasPrefix("TTT") else {
            return false
        }
        guard identCode.contains("\"type\":\"c1\"") else {
            return false
        }
        return true
    }
    
    fileprivate func generateQRCodeInputMsg(_ inputStr: String) -> String {
        
        if self.verifyCode(inputStr) {
            
            let result = inputStr.replacingOccurrences(of:"TTT:", with: "")
            let jsonData:Data = result.data(using: .utf8)!
            let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! [String : Any]
            
            var splitStr = ""
            if (dict?.keys.contains("pub"))! &&  (dict?.keys.contains("v"))! {
                let value = dict!["v"] as! Int
                splitStr = String(format:"TTT:{\"type\":\"%@\",\"id\":\"%@\",\"v\":%@}", arguments:["h1", dict!["pub"] as! String, String(value)])
            }
            return splitStr
        }
        return ""
    }
}
