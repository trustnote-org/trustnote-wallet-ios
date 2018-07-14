//
//  TNCreateCommonWalletView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/18.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TNCreateCommonWalletView: UIView {
    
    let maxInputCount = 10
    let disposeBag = DisposeBag()
    let walletViewModel = TNWalletViewModel()
    
    typealias CreateCommonWalletCompleted = () -> Void
    
    var ceateCommonWalletCompleted: CreateCommonWalletCompleted?
    
    var createEmptyWalletBlock: CreateCommonWalletCompleted?
    
    var passwordAlertView: TNPasswordAlertView?
    var verifyPasswordView: TNCustomAlertView?
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var lineHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputTextField.delegate = self
        inputTextField.placeholder = "Enter the name of your new TrustNote wallet".localized
        createButton.setTitle("Create the wallet".localized, for: .normal)
        warningLabel.text = "No more than 10 characters".localized
        createButton.layer.cornerRadius = kCornerRadius
        createButton.layer.masksToBounds = true
        let inputObserver = inputTextField.rx.text.orEmpty.asDriver().debounce(0.1).map {$0.count > 0}
        inputObserver.drive(createButton.validState).disposed(by: disposeBag)
        inputTextField.addTarget(self, action: #selector(self.textDidChanged), for: .editingChanged)
        
        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillShow)
            .subscribe(onNext: { [unowned self] _ in
                self.verifyPasswordView?.y -= 40
            }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillHide)
            .subscribe(onNext: { [unowned self] (notify) in
                self.verifyPasswordView?.y = 0
            }).disposed(by: disposeBag)
    }
}

extension TNCreateCommonWalletView {
    
    @IBAction func createNewWallet(_ sender: Any) {
        
        guard (inputTextField.text?.count)! <= maxInputCount else {
            warningView.isHidden = false
            return
        }
        let credentials = TNConfigFileManager.sharedInstance.readWalletCredentials()
        let filterCredentials = credentials.filter {
            return Double($0["balance"] as! String) == 0
        }
        guard filterCredentials.count < 2 else {
            createEmptyWalletBlock?()
            return
        }
        verifyWalletPassword()
        createButton.isEnabled = false
        createButton.alpha = 0.3
    }
    @IBAction func clearInputText(_ sender: Any) {
        createButton.isEnabled = false
        createButton.alpha = 0.3
        clearButton.isHidden = true
        inputTextField.text = nil
    }
    
    func createNewWallet() {
        
        TNGlobalHelper.shared.currentWallet.walletName = inputTextField.text!
        walletViewModel.generateNewWalletByDatabaseNumber(isLocal: true) {[unowned self] in
            self.walletViewModel.saveNewWalletToProfile(TNGlobalHelper.shared.currentWallet)
            self.walletViewModel.saveWalletDataToDatabase(TNGlobalHelper.shared.currentWallet)
            NotificationCenter.default.post(name: Notification.Name(rawValue: TNCreateCommonWalletNotification), object: nil)
            if !TNGlobalHelper.shared.currentWallet.xPubKey.isEmpty {
                self.walletViewModel.generateWalletAddress(wallet_xPubKey: TNGlobalHelper.shared.currentWallet.xPubKey, change: false, num: 0, comletionHandle: { (walletAddressModel) in
                    self.walletViewModel.insertWalletAddressToDatabase(walletAddressModel: walletAddressModel)
                    TNHubViewModel.getMyTransactionHistory(addresses: [walletAddressModel.walletAddress])
                    TNGlobalHelper.shared.password = nil
                    self.inputTextField.text = nil
                    self.ceateCommonWalletCompleted?()
                })
            }
        }
    }
    
    fileprivate func verifyWalletPassword() {
        passwordAlertView = TNPasswordAlertView.loadViewFromNib()
        verifyPasswordView = createPopView(passwordAlertView!, height: 320, animatedType: .none)
        let tap = UITapGestureRecognizer(target: self, action: #selector(TNCreateCommonWalletView.handleTapGesture))
        verifyPasswordView?.addGestureRecognizer(tap)
        passwordAlertView!.verifyCorrectBlock = {[unowned self] in
            self.createNewWallet()
            self.verifyPasswordView?.removeFromSuperview()
        }
        passwordAlertView!.didClickedCancelBlock = {[unowned self] in
            self.verifyPasswordView?.removeFromSuperview()
            self.createButton.isEnabled = true
            self.createButton.alpha = 1.0
        }
    }
    
    @objc fileprivate func handleTapGesture() {
        passwordAlertView!.passwordTextField.resignFirstResponder()
    }
    
    fileprivate func createPopView(_ alert: UIView, height: CGFloat, animatedType: TNAlertAnimatedStyle) -> TNCustomAlertView {
        let popX = CGFloat(kLeftMargin)
        let popH: CGFloat = height
        let popY = (kScreenH - popH) / 2
        let popW = kScreenW - popX * 2
        return TNCustomAlertView(alert: alert, alertFrame: CGRect(x: popX, y: popY, width: popW, height: popH), AnimatedType: animatedType)
    }
    
    @objc func textDidChanged(textField: UITextField) {
        clearButton.isHidden = (textField.text?.isEmpty)! ? true : false
    }
}

extension TNCreateCommonWalletView: TNNibLoadable {
    
    class func createCommonWalletView() -> TNCreateCommonWalletView {
        
        return TNCreateCommonWalletView.loadViewFromNib()
    }
}

extension TNCreateCommonWalletView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        clearButton.isHidden = (inputTextField.text?.isEmpty)! ? true : false
        lineHeightConstraint.constant = 2.0
        lineView.backgroundColor = kGlobalColor
        if !warningView.isHidden {
            warningView.isHidden = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        clearButton.isHidden = true
        lineHeightConstraint.constant = 1.0
        lineView.backgroundColor = kLineViewColor
    }
}

extension UIButton {
    var validState: AnyObserver<Bool> {
        return Binder(self) { button, valid in
            button.isEnabled = valid
            button.alpha = valid ? 1.0 : 0.3
            }.asObserver()
    }
}
