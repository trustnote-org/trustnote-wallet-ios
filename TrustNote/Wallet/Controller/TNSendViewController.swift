//
//  TNSendViewController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/4.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import MBProgressHUD

class TNSendViewController: TNNavigationController {

    var passwordAlertView: TNPasswordAlertView?
    
    var verifyPasswordView: TNCustomAlertView?
    
    var wallet: TNWalletModel!
    
    var sendCell: TNWalletSendCell?
    
    var transferAmount: String?
    
    var recAddress: String?
    
    var hud: MBProgressHUD?
    
    let tableView = UITableView().then {
        $0.backgroundColor = UIColor.clear
        $0.tn_registerCell(cell: TNWalletSendCell.self)
        $0.showsVerticalScrollIndicator = false
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
    }
    
    init(wallet: TNWalletModel) {
        super.init()
        self.wallet = wallet
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBackButton()
        let _ = navigationBar.setRightButtonImage(imageName: "send_scan", target: self, action: #selector(self.scanAction))
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kSafeAreaBottomH)
        }
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNTransferSendSuccessNotify)).subscribe(onNext: {[unowned self] value in
            self.hud?.removeFromSuperview()
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
    }
}

extension TNSendViewController {
    
    @objc fileprivate func scanAction() {
        let scan = TNScanViewController()
        scan.isPush = false
        scan.scanningCompletionBlock = {[unowned self] prefixResult in
           self.handleScanningResult(prefixResult: prefixResult)
        }
        navigationController?.present(scan, animated: true, completion: nil)
    }
    
    fileprivate func handleScanningResult(prefixResult: String) {
        guard prefixResult.contains(TNScanPrefix) else {
            return
        }
        let result = prefixResult.replacingOccurrences(of: TNScanPrefix, with: "")
        if result.contains("?") {
            let components = result.components(separatedBy: "?")
            sendCell?.addressTextField.text = components.first
            let amountStr = components.last
            guard (amountStr?.contains("amount="))! else {
                return
            }
            let amount = amountStr!.replacingOccurrences(of: "amount=", with: "")
            if String.isOnlyNumber(str: amount) {
                sendCell?.amountTextField.text = String(format: "%.4f", Double(amount)! / kBaseOrder)
                if sendCell!.amountTextField.isFirstResponder {
                    sendCell!.clearBtn.isHidden = false
                }
            }
        } else {
            sendCell?.addressTextField.text = result
        }
        if !(sendCell?.addressTextField.text?.isEmpty)! && !(sendCell?.amountTextField.text?.isEmpty)! {
            sendCell?.confirmBtn.isEnabled = true
            sendCell?.confirmBtn.alpha = 1.0
        }
    }
    
    @objc fileprivate func handleTapGesture() {
        passwordAlertView!.passwordTextField.resignFirstResponder()
    }
    
    fileprivate func verifyWalletPassword() {
        passwordAlertView = TNPasswordAlertView.loadViewFromNib()
        passwordAlertView?.delegate = self
        verifyPasswordView = createPopView(passwordAlertView!, height: kVerifyPasswordAlertHeight, animatedType: .pop)
        let tap = UITapGestureRecognizer(target: self, action: #selector(TNSendViewController.handleTapGesture))
        verifyPasswordView?.addGestureRecognizer(tap)
    }
    
    fileprivate func startToSend() {
        var paymentInfo = TNPaymentInfo()
        paymentInfo.amount = transferAmount!
        paymentInfo.receiverAddress = recAddress!
        paymentInfo.walletId = wallet.walletId
        paymentInfo.walletPubkey = wallet.xPubKey
        let sendViewModel = TNTransferViewModel(paymentInfo: paymentInfo)
        sendViewModel.sendFailureBlock = {[unowned self] in
            self.hud?.removeFromSuperview()
            MBProgress_TNExtension.showViewAfterSecond(title: "发送失败")
        }
        sendViewModel.getReadyToSend()
    }
    
    fileprivate func createPopView(_ alert: UIView, height: CGFloat, animatedType: TNAlertAnimatedStyle) -> TNCustomAlertView {
        let popX = CGFloat(kLeftMargin)
        let popH: CGFloat = height
        let popY = (kScreenH - popH) / 2
        let popW = kScreenW - popX * 2
        return TNCustomAlertView(alert: alert, alertFrame: CGRect(x: popX, y: popY, width: popW, height: popH), AnimatedType: animatedType)
    }
}

extension TNSendViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TNWalletSendCell = tableView.tn_dequeueReusableCell(indexPath: indexPath)
        let attrStr = NSMutableAttributedString(string: wallet.balance)
        let length = wallet.balance.length
        attrStr.addAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 26)], range: NSRange(location: 0, length: length - TNGlobalHelper.shared.unitDecimals))
        attrStr.addAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 22)], range: NSRange(location: length - TNGlobalHelper.shared.unitDecimals, length: TNGlobalHelper.shared.unitDecimals))
        cell.balanceLabel.attributedText = attrStr
        cell.checkoutBtn.isHidden = wallet.isLocal ? true : false
        cell.instructionLabel.isHidden = wallet.isLocal ? true : false
        cell.confirmBtnBottomMarginConstraint.constant = wallet.isLocal ? CGFloat(kLeftMargin) : 90
        sendCell = cell
        sendCell?.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kScreenH - kNavBarHeight - kSafeAreaBottomH
    }
}

extension TNSendViewController: TNWalletSendCellProtocol {
    
    func transfer(amount: String, recieverAddress: String) {
        transferAmount = amount
        recAddress = recieverAddress
        verifyWalletPassword()
    }
    
    func selectTrancsationAddress() {
        
        let vc = TNContactAddressController {[unowned self] (seletedAddress) in
            self.sendCell?.addressTextField.text = seletedAddress
            if !(self.sendCell?.amountTextField.text?.isEmpty)! {
                self.sendCell?.confirmBtn.isEnabled = true
                self.sendCell?.confirmBtn.alpha = 1.0
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension TNSendViewController: TNPasswordAlertViewDelegate {
    
    func passwordVerifyCorrect(_ password: String) {
        startToSend()
        verifyPasswordView?.removeFromSuperview()
        let view = UIApplication.shared.delegate?.window as? UIView
        hud = MBProgress_TNExtension.showHUDAddedToView(view: view!, title: "加载中...", animated: true)
    }
    
    func didClickedCancelButton() {
        verifyPasswordView?.removeFromSuperview()
    }
}

