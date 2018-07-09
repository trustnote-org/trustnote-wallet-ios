//
//  TNWalletDetailController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/25.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNWalletDetailController: TNNavigationController {
    
    var walletModel: TNWalletModel!
    var address: String!
    var passwordAlertView: TNPasswordAlertView?
    var verifyPasswordView: TNCustomAlertView?
    let items = [["title": "Wallet name".localized,  "action": "modifyWalletName"], ["title": "Wallet ID".localized,  "action": ""]/*, ["title": "Cold wallet authentication code".localized,  "action": "checkoutAuthCode"]*/]
    
    fileprivate lazy var detailHeaderView: TNWalletDetailHeaderView = {
        let detailHeaderView = TNWalletDetailHeaderView.walletDetailHeaderView()
        return detailHeaderView
    }()
    
    fileprivate lazy var deleteWalletAlertView: TNDeleteWalletAlertView = {
        let deleteWalletAlertView = TNDeleteWalletAlertView.loadViewFromNib()
        return deleteWalletAlertView
    }()
    
    
    let tableView = UITableView().then {
        $0.backgroundColor = UIColor.clear
        $0.tn_registerCell(cell: TNWalletDetailCell.self)
        $0.showsVerticalScrollIndicator = false
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
        $0.isScrollEnabled = false
    }
    
    let deleteBtn = UIButton().then {
        $0.setTitle("Delete wallet".localized, for: .normal)
        $0.setTitleColor(kGlobalColor, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        $0.layer.cornerRadius = kCornerRadius
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1.0
        $0.layer.borderColor = kGlobalColor.cgColor
        $0.addTarget(self, action: #selector(TNWalletDetailController.deleteCurrentWallet), for: .touchUpInside)
    }
    
    init(wallet: TNWalletModel, address: String) {
        super.init()
        self.walletModel = wallet
        self.address = address
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        detailHeaderView.walletModel = walletModel
        detailHeaderView.addressLabel.text = address
        tableView.delegate = self
        tableView.dataSource = self
        setupSubview()
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNModifyWalletNameNotification)).subscribe(onNext: { [unowned self] value in
            self.walletModel.walletName = value.object as! String
            self.detailHeaderView.walletNameLabel.text = value.object as? String
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillShow)
            .subscribe(onNext: { [unowned self] _ in
                self.verifyPasswordView?.y -= 40
            }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillHide)
            .subscribe(onNext: { [unowned self] (notify) in
                 self.verifyPasswordView?.y = 0
            }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = kBackgroundColor
    }
}

extension TNWalletDetailController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if walletModel.isLocal {
            return items.count
        }
        return items.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TNWalletDetailCell = tableView.tn_dequeueReusableCell(indexPath: indexPath)
        cell.titleTextLabel.text = items[indexPath.row]["title"]
        if indexPath.row == 0 {
            cell.detailLabel.text = walletModel.walletName
        }
        if indexPath.row == 1 {
            cell.detailLabel.textAlignment = .left
            cell.detailLabel.text = walletModel!.walletId
        }
        cell.cellIndex = indexPath.row
        cell.lineView.isHidden = indexPath.row == tableView.numberOfRows(inSection: 0) - 1 ? true : false
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row  == 1 {
            return 72.0
        }
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let action: String = items[indexPath.row]["action"]! 
        guard !action.isEmpty else {
            return
        }
        let control: UIControl = UIControl()
        control.sendAction(Selector(action), to: self, for: nil)
    }
}
/// MARK: Handle event
extension TNWalletDetailController {
   
    @objc fileprivate func modifyWalletName() {
        let vc = TNEditInfoController(isEditInfo: false)
        vc.wallet = walletModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func checkoutAuthCode() {
        verifyWalletPassword(action: "checkoutAuthCodeVerifyCompleted")
    }
    
    @objc fileprivate func deleteCurrentWallet() {
        
         let deleteWarningView = createPopView(deleteWalletAlertView, height: 260, animatedType: .transform)
        deleteWalletAlertView.didClickedCancelBlock = {
            deleteWarningView.removeFromSuperview()
        }
        deleteWalletAlertView.didClickedConfirmBlock = {[unowned self] in
            
            deleteWarningView.removeFromSuperview()
            guard Double(self.walletModel.balance)! > 0 && self.walletModel!.isLocal else {
                self.verifyWalletPassword(action: "deleteWalletVerifyCompleted")
                return
            }
            self.alertAction(self, "Unable to delete hints".localized, message: nil, sureActionText: nil, cancelActionText: "Confirm".localized, isChange: false, sureAction: nil)
        }
    }
    
    @objc fileprivate func checkoutAuthCodeVerifyCompleted() {
        let vc = TNWalletAuthCodeController(nibName: "\(TNWalletAuthCodeController.self)", bundle: nil)
        vc.wallet = walletModel
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc fileprivate func deleteWalletVerifyCompleted() {
        var credentials  = TNConfigFileManager.sharedInstance.readWalletCredentials()
        for (index, dict) in credentials.enumerated() {
            if dict["walletId"] as? String == self.walletModel.walletId {
                credentials.remove(at: index)
                break
            }
        }
        TNConfigFileManager.sharedInstance.updateProfile(key: "credentials", value: credentials)
        NotificationCenter.default.post(name: Notification.Name(rawValue: TNDidFinishDeleteWalletNotification), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func verifyWalletPassword(action: String) {
        passwordAlertView = TNPasswordAlertView.loadViewFromNib()
        verifyPasswordView = createPopView(passwordAlertView!, height: 320, animatedType: .none)
        let tap = UITapGestureRecognizer(target: self, action: #selector(TNWalletDetailController.handleTapGesture))
        verifyPasswordView?.addGestureRecognizer(tap)
        passwordAlertView!.verifyCorrectBlock = {[unowned self] in
            self.verifyPasswordView?.removeFromSuperview()
            TNGlobalHelper.shared.password = nil
            let control: UIControl = UIControl()
            control.sendAction(Selector(action), to: self, for: nil)
        }
       passwordAlertView!.didClickedCancelBlock = {[unowned self] in
            self.verifyPasswordView?.removeFromSuperview()
        }
    }
    
    @objc fileprivate func handleTapGesture() {
        passwordAlertView!.passwordTextField.resignFirstResponder()
    }
}

/// MARK: Custom Method
extension TNWalletDetailController {
    
    fileprivate func createPopView(_ alert: UIView, height: CGFloat, animatedType: TNAlertAnimatedStyle) -> TNCustomAlertView {
        let popX = CGFloat(kLeftMargin)
        let popH: CGFloat = height
        let popY = (kScreenH - popH) / 2
        let popW = kScreenW - popX * 2
        return TNCustomAlertView(alert: alert, alertFrame: CGRect(x: popX, y: popY, width: popW, height: popH), AnimatedType: animatedType)
    }
}

extension TNWalletDetailController {
    
    fileprivate func setupSubview() {
        
        view.addSubview(detailHeaderView)
        detailHeaderView.snp.makeConstraints { (make) in
             make.top.equalTo(navigationBar.snp.bottom)
             make.left.right.equalToSuperview()
             make.height.equalTo(184)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(detailHeaderView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kSafeAreaBottomH)
        }
        
        view.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kLeftMargin)
            make.bottom.equalToSuperview().offset(-(kSafeAreaBottomH + CGFloat(kLeftMargin)))
            make.height.equalTo(48)
            make.centerX.equalToSuperview()
        }
    }
}
