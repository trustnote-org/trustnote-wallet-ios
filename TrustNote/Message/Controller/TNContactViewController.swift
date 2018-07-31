//
//  TNContactViewController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/25.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNContactViewController: TNBaseViewController {
    
    var dataSource: [TNCorrespondentDevice] = []
    var wallets: [TNWalletModel] = []
    var selectWalletListView: TNCustomAlertView?
    var scanningResult: String?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var topBarheightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topBarheightConstraint.constant = IS_iPhoneX ? 118 : 94
        detailLabel.text = "NoContactsDesc".localized
        descLabel.text = "No contacts".localized
        titleLabel.text = "Contacts".localized
        configTableView()
        
        topBar.setupShadow(Offset: CGSize(width: 0, height: 5), opacity: 0, radius: 5)
        getCorrespondentList()
        getWalletList()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didAddContact), name: NSNotification.Name(rawValue: TNAddContactCompletedNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.recieveConfirmedNotification), name: NSNotification.Name(rawValue: TNAddContactConfirmedNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.recieveNewMessage), name: NSNotification.Name(rawValue: TNDidRecievedMessageNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendMessageToOther), name: NSNotification.Name(rawValue: TNSendMessageToOtherNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.recieveRemovedMessage), name: NSNotification.Name(rawValue: TNDidRecievedRemovedNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.recieveConfirmedNotification), name: NSNotification.Name(rawValue: TNDidSetAliasSuccessNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeContactAllChatReccords), name: NSNotification.Name(rawValue: TNDidRemovedAllChatRecordsNotify), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = kBackgroundColor
    }
    
    fileprivate func configTableView() {
        tableView.tn_registerCell(cell: TNContactCell.self)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TNContactViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TNContactCell = tableView.tn_dequeueReusableCell(indexPath: indexPath)
        cell.model = dataSource[indexPath.row]
        if indexPath.row % 3 == 2 {
            cell.markLabel.backgroundColor = UIColor.hexColor(rgbValue: 0xFFF1DA)
            cell.markLabel.textColor = UIColor.hexColor(rgbValue: 0xFFF1DA)
        } else {
            cell.markLabel.backgroundColor = UIColor.hexColor(rgbValue: 0xEAF2FF)
            cell.markLabel.textColor = UIColor.hexColor(rgbValue: 0xEAF2FF)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let correspondent = dataSource[indexPath.row]
        let chatController = TNChatViewController(device: correspondent.deviceAddress)
        navigationController?.pushViewController(chatController, animated: true)
        guard correspondent.unreadCount > 0 else {
            return
        }
        var model = correspondent
        model.unreadCount = 0
        dataSource[indexPath.row] = model
        showBadgeView()
        tableView.reloadData()
        TNSQLiteManager.sharedManager.updateData(sql: "UPDATE correspondent_devices SET unread=0 WHERE device_address=?", values: [correspondent.deviceAddress])
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y > 0 {
            topBar.layer.shadowOpacity = 0.1
        } else {
            topBar.layer.shadowOpacity = 0
        }
    }
}

/// MARK: action
extension TNContactViewController {
    
    @IBAction func popAction(_ sender: Any) {
        let popW: CGFloat = TNLocalizationTool.shared.currentLanguage == "en" ? 174 : 154
        let popH: CGFloat = 44.0
        let popX = kScreenW - popW - 12.0
        let popY: CGFloat = topBar.frame.maxY - 22
        let imageNameArr = ["wallet_sao", "wallet_contact", "wallet_group", "wallet_code"]
        let titleArr = ["Scan QR Code".localized, "Add Contact".localized,"Create Wallet".localized, "My Matching Code".localized]
        let popView = TNPopView(frame: CGRect(x: popX, y: popY, width: popW, height: popH), imageNameArr: imageNameArr, titleArr: titleArr)
        popView.delegate = self
    }
    
    @objc fileprivate func didAddContact(notify: Notification) {
        let correspondent = notify.object as! TNCorrespondentDevice
        dataSource.insert(correspondent, at: 0)
        DispatchQueue.main.async {
            if !self.dataSource.isEmpty {
                self.containerView.isHidden = true
            }
            self.updateTableView()
        }
    }
    
    @objc fileprivate func recieveConfirmedNotification(notify: Notification) {
        DispatchQueue.main.async {
            let object = notify.object as! [String: String]
            let device = object["from"]
            for (index, correspondent) in self.dataSource.enumerated() {
                if correspondent.deviceAddress == device {
                    var newCorrespondent = correspondent
                    newCorrespondent.name = object["deviceName"]!
                    self.dataSource[index] = newCorrespondent
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    break
                }
            }
            self.showBadgeView()
        }
    }
    
    @objc fileprivate func recieveNewMessage(notify: Notification) {
        DispatchQueue.main.async {
            let object = notify.object as! [String: Any]
            let decryptedObj = object["messageObj"] as! [String: Any]
            let device = decryptedObj["from"] as! String
            var flag = true
            let topController = self.navigationController!.topViewController
            if topController!.isKind(of: TNChatViewController.self) {
                let vc = topController as! TNChatViewController
                if vc.deviceAddress == device {
                    flag = false
                }
            }
            if flag {
                for (index, correspondent) in self.dataSource.enumerated() {
                    if device == correspondent.deviceAddress {
                        var model = correspondent
                        model.unreadCount += 1
                        self.dataSource[index] = model
                        TNSQLiteManager.sharedManager.updateData(sql: "UPDATE correspondent_devices SET unread=? WHERE device_address=?", values: [model.unreadCount, correspondent.deviceAddress])
                    }
                }
            }
            self.refreshAction(device: device)
        }
    }
    
    @objc fileprivate func sendMessageToOther(notify: Notification) {
        let device = notify.object as! String
        refreshAction(device: device)
    }
    
    @objc fileprivate func recieveRemovedMessage(notify: Notification) {
        DispatchQueue.main.async {
            let device = notify.object as! String
            for (index, correspondent) in self.dataSource.enumerated() {
                if correspondent.deviceAddress == device {
                    self.dataSource.remove(at: index)
                    if self.dataSource.isEmpty {
                        self.containerView.isHidden = false
                    }
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    break
                }
            }
            self.showBadgeView()
        }
    }
    
    @objc fileprivate func removeContactAllChatReccords(notify: Notification) {
        tableView.reloadData()
    }
}

extension TNContactViewController: TNSelectWalletViewDelegate {
    
    func dismiss() {
        selectWalletListView?.removeFromSuperview()
    }
    
    func didSelectedWallet(wallet: TNWalletModel) {
        let vc = TNSendViewController(wallet: wallet)
        if scanningResult!.contains("?amount=") {
            let strArr = scanningResult!.components(separatedBy: "?amount=")
            vc.transferAmount = strArr.last
            vc.recAddress = strArr.first
        } else {
            vc.recAddress = scanningResult
        }
        navigationController?.pushViewController(vc, animated: true)
        selectWalletListView?.removeFromSuperview()
    }
}

extension TNContactViewController: TNPopCtrlCellClickDelegate {
    
    func popCtrlCellClick(tag: Int) {
        switch tag {
        case TNPopItem.scan.rawValue :
            let scanning = TNScanViewController()
            if wallets.count > 1 {
                scanning.scanningCompletionBlock = {[unowned self] (result) in
                    self.scanningResult = result
                    self.showSelectList()
                }
            }
            navigationController?.pushViewController(scanning, animated: true)
        case TNPopItem.addContacts.rawValue :
            navigationController?.pushViewController(TNAddContactsController(), animated: true)
        case TNPopItem.createWallet.rawValue:
            navigationController?.pushViewController(TNCreateWalletController(), animated: true)
        case TNPopItem.MatchingCode.rawValue:
            showPairingCode()
        default:
            break
        }
    }
}
/// MARK: Custom methods
extension TNContactViewController {
    
    fileprivate func getCorrespondentList() {
        TNSQLiteManager.sharedManager.queryAllCorrespondents {[unowned self] (correspondents) in
            self.dataSource = correspondents
            if !self.dataSource.isEmpty {
                self.containerView.isHidden = true
            }
            self.tableView.reloadData()
        }
    }
    
    fileprivate func updateTableView() {
        tableView.beginUpdates()
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .none)
        tableView.endUpdates()
        showBadgeView()
    }
    
    fileprivate func refreshAction(device: String) {
        for (index, correspondent) in dataSource.enumerated() {
            if correspondent.deviceAddress == device {
                if index == 0 {
                    tableView.reloadData()
                    break
                }
                let newCorrespondent = correspondent
                dataSource.remove(at: index)
                dataSource.insert(newCorrespondent, at: 0)
                tableView.reloadData()
                break
            }
        }
        showBadgeView()
    }
    
    fileprivate func showPairingCode() {
        let myPairingCodeView = TNMyPairingCodeView.loadViewFromNib()
        myPairingCodeView.generateQRcode {
            let popX = CGFloat(kLeftMargin)
            let popH: CGFloat  = IS_iphone5 ? 512 : 492
            let popY = (kScreenH - popH) / 2
            let popW = kScreenW - popX * 2
            let alertView = TNCustomAlertView(alert: myPairingCodeView, alertFrame: CGRect(x: popX, y: popY, width: popW, height: popH), AnimatedType: .transform)
            myPairingCodeView.dimissBlock = {
                alertView.removeFromSuperview()
            }
        }
    }
    
    fileprivate func showSelectList() {
        let popX = CGFloat(kLeftMargin)
        let popH: CGFloat = CGFloat(wallets.count) * selectWalletRowHeight + selectWalletHeaderHeight > kScreenH - 180 ? (kScreenH - 180) : (CGFloat(wallets.count) * selectWalletRowHeight + selectWalletHeaderHeight)
        let popY = (kScreenH - popH) / 2
        let popW = kScreenW - popX * 2
        
        let alertView = TNSelectWalletView(frame: CGRect(x: popX, y: popY, width: popW, height: popH), wallets: wallets)
        alertView.delegate = self
        selectWalletListView = TNCustomAlertView(alert: alertView, alertFrame: CGRect(x: popX, y: popY, width: popW, height: popH), AnimatedType: .none)
    }
    
    fileprivate func showBadgeView() {
        
        let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as! TNTabBarController
        let tabBar = tabBarVC.tabBar
        var newMessageCount = 0
        for correspondent in dataSource {
            newMessageCount += correspondent.unreadCount
        }
        if newMessageCount == 0 {
           tabBar.hideBadgeOnItemIndex(1)
        } else {
          tabBar.showBadgeOnItemIndex(1)
        }
    }
    
    fileprivate func getWalletList() {
        
        let credentials = TNConfigFileManager.sharedInstance.readWalletCredentials()
        for dict in credentials {
            let walletModel = TNWalletModel.deserialize(from: dict)
            wallets.append(walletModel!)
        }
    }
}

