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
    
    let walletViewModel = TNWalletViewModel()
    let recoverOperation = TNRecoverObserveWallet()
    
    fileprivate var isImportValid: BehaviorRelay<Bool> =  BehaviorRelay(value: false)
    fileprivate var isCompletionValid: BehaviorRelay<Bool> =  BehaviorRelay(value: false)
    
    var scanningResultDict: [String : Any]?
    
    let startAuthAlert = TNObserveWaletAlertView.observeWaletAlertView()
    let authCompletedAlert = TNAuthDoneAlertView.authDoneAlertView()
    var authCompletedAlertView: TNCustomAlertView?
    var syncLoadingView : TNCustomAlertView?
    
    private let titleTextLabel = UILabel().then {
        $0.text =  NSLocalizedString("Create a TTT wallet", comment: "")
        $0.textColor = kTitleTextColor
        $0.font = UIFont.boldSystemFont(ofSize: 24.0)
    }
    
    private let scrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.bounces = false
        $0.isPagingEnabled = true
        $0.contentSize = CGSize(width: 2 * kScreenW, height: 0)
    }
    
    fileprivate lazy var loadingView: TNSyncClonedWalletsView = {
        let loadingView = TNSyncClonedWalletsView.loadViewFromNib()
        loadingView.loadingText.text = "SyncLoading".localized
        return loadingView
    }()
    
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
        commonWalletView.ceateCommonWalletCompleted = {[unowned self] in
            self.navigationController?.popViewController(animated: true
            )
        }
        observeWalletView.clickedImportButtonBlock = {[unowned self] in
            let marginX: CGFloat = 6.0
            let marginY: CGFloat = 58.0
            let alertFrame = CGRect(x: marginX, y: marginY, width: kScreenW - 2 * marginX, height: kScreenH - 2 * marginY)
            self.generateQRCodeInputMsg {
                let value = self.scanningResultDict!["v"] as! Int
                let qrInput = String(format:"TTT:{\"type\":\"%@\",\"id\":\"%@\",\"v\":%@}", arguments:["h1", TNGlobalHelper.shared.currentWallet.walletId , String(value)])
                /// create qrCode
                self.startAuthAlert.qrCodeImageView.image = UIImage.createHDQRImage(input: qrInput , imgSize: self.startAuthAlert.qrCodeImageView.size)
                let authAlertView = TNCustomAlertView(alert: self.startAuthAlert, alertFrame: alertFrame, AnimatedType: .transform)
                self.startAuthAlert.dismissBlock = {
                    authAlertView.removeFromSuperview()
                }
            }
        }
        
        startAuthAlert.clickedNextButtonBlock = {[unowned self] in
            self.startAuthAlert.dismissBlock?()
            let marginX: CGFloat = 26.0
            let marginY: CGFloat = 78.0
            let alertFrame = CGRect(x: marginX, y: marginY, width: kScreenW - 2 * marginX, height: kScreenH - 2 * marginY)
            self.authCompletedAlertView = TNCustomAlertView(alert: self.authCompletedAlert, alertFrame: alertFrame, AnimatedType: .none)
        }
        authCompletedAlert.clickedDoneButtonBlock = {[unowned self] in
            self.walletViewModel.saveNewWalletToProfile(TNGlobalHelper.shared.currentWallet)
            self.walletViewModel.saveWalletDataToDatabase(TNGlobalHelper.shared.currentWallet)
            self.recoverOperation.isRecoverWallet = true
            TNGlobalHelper.shared.recoverStyle = .observed
            self.loadingView.startAnimation()
            let popX = CGFloat(kLeftMargin)
            let popH: CGFloat = 190
            let popY = (kScreenH - popH) / 2
            let popW = kScreenW - popX * 2
            self.syncLoadingView = TNCustomAlertView(alert: self.loadingView, alertFrame: CGRect(x: popX, y: popY, width: popW, height: popH), AnimatedType: .none)
            self.recoverOperation.recoverObserveWallet(TNGlobalHelper.shared.currentWallet)
            self.authCompletedAlertView?.removeFromSuperview()
        }
        
        isImportValid.asDriver().drive(observeWalletView.importButton.rx_validState).disposed(by: self.disposeBag)
        isCompletionValid.asDriver().drive(authCompletedAlert.doneBtn.rx_validState).disposed(by: self.disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNDidFinishRecoverWalletNotification)).subscribe(onNext: {[unowned self] value in
            TNGlobalHelper.shared.recoverStyle = .none
            self.recoverOperation.isRecoverWallet = false
            self.loadingView.stopAnimation()
            self.syncLoadingView?.removeFromSuperview()
            NotificationCenter.default.post(name: Notification.Name(rawValue: TNCreateObserveWalletNotification), object: nil)
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
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
                let isValid = self.verifyFirstCode(result)
                self.isImportValid.accept(isValid)
                self.observeWalletView.invalidLabel.isHidden = isValid ? true : false
                self.observeWalletView.invalidImgview.isHidden = isValid ? true : false
                if isValid {
                    TNGlobalHelper.shared.currentWallet.isLocal = false
                    let dict = self.covertJSonStingToDictionary(result)
                    self.scanningResultDict = dict
                    if dict.keys.contains("n") {
                        TNGlobalHelper.shared.currentWallet.account = dict["n"] as! Int
                    }
                    if dict.keys.contains("name") {
                        TNGlobalHelper.shared.currentWallet.walletName = dict["name"] as! String
                    }
                    if dict.keys.contains("pub") {
                        TNGlobalHelper.shared.currentWallet.publicKeyRing = [["xPubKey": dict["pub"]]]
                    }
                    TNGlobalHelper.shared.currentWallet.creation_date = NSDate.getCurrentFormatterTime()
                    TNGlobalHelper.shared.currentWallet.xPubKey = dict["pub"] as! String
                }
            }
        }
        
        authCompletedAlert.clickedScanButtonBlock = {[unowned self] in
            let scanningVC = TNScanViewController()
            self.authCompletedAlertView?.removeFromSuperview()
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
                let isValid = self.verifySecondCode(result)
                self.authCompletedAlert.invalidImgview.isHidden = isValid ? true : false
                self.authCompletedAlert.invalidLabel.isHidden = isValid ? true : false
                self.isCompletionValid.accept(isValid)
                if isValid {
                    TNGlobalHelper.shared.my_device_address = self.scanningResultDict!["addr"] as! String
                }
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
    
    fileprivate func verifyFirstCode(_ identCode: String) -> Bool {
        
        guard identCode.hasPrefix("TTT") else {
            return false
        }
        guard identCode.contains("\"type\":\"c1\"") else {
            return false
        }
        return true
    }
    
    fileprivate func verifySecondCode(_ identCode: String) -> Bool {
        guard identCode.hasPrefix("TTT") else {
            return false
        }
        guard identCode.contains("\"type\":\"c2\"") else {
            return false
        }
        let codeDict = covertJSonStingToDictionary(identCode)
        if codeDict.keys.contains("v") {
            let value = codeDict["v"] as! Int
            if value == (scanningResultDict!["v"] as! Int) && codeDict.keys.contains("addr") {
                scanningResultDict = codeDict
                return true
            }
        }
        return false
    }
    
    fileprivate func generateQRCodeInputMsg(completion: (() -> Swift.Void)?) {
        
        if scanningResultDict!.keys.contains("pub") &&  scanningResultDict!.keys.contains("v") {
            TNEvaluateScriptManager.sharedInstance.getWalletID(walletPubKey: scanningResultDict?["pub"] as! String, completed: completion)
        }
    }
    
    fileprivate func covertJSonStingToDictionary(_ inputStr: String) -> [String : Any] {
        let result = inputStr.replacingOccurrences(of:"TTT:", with: "")
        let jsonData:Data = result.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! [String : Any]
        return dict!
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

