//
//  TNWalletHomeController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/16.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import Reachability
import ReusableKit

class TNWalletHomeController: TNBaseViewController {
    
    struct Reusable {
        static let networkStatusCell = "\(TNNetworkStatusCell.self)"
        static let totalAssertCell = "\(TNTotalAssertCell.self.self)"
        static let walletCell = "\(TNWalletCell.self)"
    }
    let walletCellHeight: CGFloat = 86.0
    let networkStatusCellHeight: CGFloat = 46.0
    let totalAssertCellHeight: CGFloat = 140.0
    
    var dataSource: [TNWalletModel] = []
    let reachability = Reachability()!
    var isReachable: Bool = true
    var totalAssert = 0.0
    var selectWalletListView: TNCustomAlertView?
    var syncOperation: TNSyncWalletData?
    var scanningResult: String?
    
    private let tableView = UITableView().then {
        $0.backgroundColor = UIColor.clear
        $0.register(UINib(nibName: Reusable.networkStatusCell, bundle: nil), forCellReuseIdentifier: Reusable.networkStatusCell)
        $0.register(UINib(nibName: Reusable.totalAssertCell, bundle: nil), forCellReuseIdentifier: Reusable.totalAssertCell)
        $0.register(UINib(nibName: Reusable.walletCell, bundle: nil), forCellReuseIdentifier: Reusable.walletCell)
        $0.tableHeaderView = UIView()
        $0.tableHeaderView?.height = 44 + kStatusbarH
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
    }
    
    fileprivate lazy var topBar: TNWalletTopBar = {
        let topBarView = TNWalletTopBar.walletTopBar()
        return topBarView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if TNGlobalHelper.shared.isVerifyPasswdForMain {
            let vc = TNVerifyPasswordController()
            navigationController?.present(vc, animated: false) {
                TNGlobalHelper.shared.mnemonic = ""
                vc.passwordAlertView.passwordTextField.becomeFirstResponder()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = kBackgroundColor
        observeNetworkStatus()
        getWalletList()
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        setupUI()
        topBar.clickedAddButtonBlock = {[unowned self] in
            self.barBtnItemClick()
        }
        
        registerNotification()
        
        if TNGlobalHelper.shared.isNeedLoadData {
            syncOperation = TNSyncWalletData()
            loadData()
        }
    }
    
    fileprivate func setupUI() {
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kSafeAreaBottomH)
        }
        
        view.addSubview(topBar)
        topBar.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kStatusbarH)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
    }
    
    deinit {
        reachability.stopNotifier()
    }
}

extension TNWalletHomeController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return isReachable ? 1 : 2
        }
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let totalAssertCell = tableView.dequeueReusableCell(withIdentifier: Reusable.totalAssertCell) as! TNTotalAssertCell
            totalAssertCell.totalAssert = totalAssert
            totalAssertCell.selectionStyle = .none
            guard isReachable else {
                if indexPath.row == 0 {
                    let networkStatusCell = tableView.dequeueReusableCell(withIdentifier: Reusable.networkStatusCell) as! TNNetworkStatusCell
                    networkStatusCell.selectionStyle = .none
                    return networkStatusCell
                } else {
                    return totalAssertCell
                }
            }
            return totalAssertCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: Reusable.walletCell) as! TNWalletCell
        cell.model = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            guard isReachable else {
                if indexPath.row == 0 {
                    return networkStatusCellHeight
                } else {
                    return totalAssertCellHeight
                }
            }
            return totalAssertCellHeight
        }
        return walletCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let walletModel = dataSource[indexPath.row]
        let listVC = TNTradeRecordsListController(wallet: walletModel)
        navigationController?.pushViewController(listVC, animated: true)
    }
}

extension TNWalletHomeController: TNSelectWalletViewDelegate {
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

extension TNWalletHomeController: TNPopCtrlCellClickDelegate {
    
    func popCtrlCellClick(tag: Int) {
        switch tag {
        case TNPopItem.scan.rawValue :
            let scanning = TNScanViewController()
            if dataSource.count > 1 {
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

extension TNWalletHomeController {
    
    fileprivate func observeNetworkStatus() {
        reachability.whenReachable = {[unowned self] reachability in
            self.isReachable = true
            self.tableView.reloadData()
            TNDebugLogManager.debugLog(item: "Reachable")
        }
        reachability.whenUnreachable = {[unowned self] _ in
            self.isReachable = false
            self.tableView.reloadData()
            TNDebugLogManager.debugLog(item: "Not reachable")
        }
        do {
            try reachability.startNotifier()
        } catch {
            TNDebugLogManager.debugLog(item: "Unable to start notifier")
        }
    }
    
    fileprivate func refreshAction() {
        dataSource.removeAll()
        getWalletList()
        tableView.reloadData()
    }
    
    fileprivate func getWalletList() {
        
        let credentials = TNConfigFileManager.sharedInstance.readWalletCredentials()
        for dict in credentials {
            let walletModel = TNWalletModel.deserialize(from: dict)
            dataSource.append(walletModel!)
        }
        getTotalAsset(wallets: dataSource)
    }
    
    fileprivate func getTotalAsset(wallets: Array<TNWalletModel>) {
        totalAssert = 0.0
        for walletModel in wallets {
            totalAssert += (walletModel.balance as NSString).doubleValue
        }
    }
    
    fileprivate func barBtnItemClick() {
        
        let popW: CGFloat = TNLocalizationTool.shared.currentLanguage == "en" ? 174 : 154
        let popH: CGFloat = popRowHeight
        let popX = kScreenW - popW - popRightMargin
        let popY: CGFloat = topBar.frame.maxY + 8.0
        let imageNameArr = ["wallet_sao", "wallet_contact", "wallet_group", "wallet_code"]
        let titleArr = ["Scan QR Code".localized, "Add Contact".localized,"Create Wallet".localized, "My Matching Code".localized]
        let popView = TNPopView(frame: CGRect(x: popX, y: popY, width: popW, height: popH), imageNameArr: imageNameArr, titleArr: titleArr)
        popView.delegate = self
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
        let popH: CGFloat = CGFloat(dataSource.count) * selectWalletRowHeight + selectWalletHeaderHeight > kScreenH - 180 ? (kScreenH - 180) : (CGFloat(dataSource.count) * selectWalletRowHeight + selectWalletHeaderHeight)
        let popY = (kScreenH - popH) / 2
        let popW = kScreenW - popX * 2
        
        let alertView = TNSelectWalletView(frame: CGRect(x: popX, y: popY, width: popW, height: popH), wallets: dataSource)
        alertView.delegate = self
        selectWalletListView = TNCustomAlertView(alert: alertView, alertFrame: CGRect(x: popX, y: popY, width: popW, height: popH), AnimatedType: .none)
    }
    
    fileprivate func loadData() {
        
        if TNWebSocketManager.sharedInstance.socket.isConnected {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.syncData()
            }
        } else {
            TNWebSocketManager.sharedInstance.socketDidConnectedBlock = {[unowned self] in
                self.syncData()
                TNWebSocketManager.sharedInstance.socketDidConnectedBlock = nil
            }
        }
    }
}

extension TNWalletHomeController {
    
    public func syncData() {
        if let syncOperation = syncOperation {
            syncOperation.syncWalletsData(wallets: dataSource)
        } else {
            TNSyncWalletData().syncWalletsData(wallets: dataSource)
        }
    }
}

extension TNWalletHomeController {
    
    fileprivate func registerNotification() {
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNDidFinishUpdateDatabaseNotification)).subscribe(onNext: {[unowned self] value in
            let viewModel = TNWalletBalanceViewModel()
            viewModel.queryAllWallets(completion: { (walletModels) in
                self.dataSource = walletModels
                self.getTotalAsset(wallets: self.dataSource)
                self.tableView.reloadData()
            })
        }).disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNCreateCommonWalletNotification)).subscribe(onNext: {[unowned self] value in
            self.refreshAction()
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNDidFinishSyncClonedWalletNotify)).subscribe(onNext: {[unowned self] value in
            self.refreshAction()
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNCreateObserveWalletNotification)).subscribe(onNext: {[unowned self] value in
            self.dataSource.removeAll()
            self.getWalletList()
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNDidFinishDeleteWalletNotification)).subscribe(onNext: { [unowned self] value in
            self.refreshAction()
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNModifyWalletNameNotification)).subscribe(onNext: { [unowned self] value in
           self.refreshAction()
        }).disposed(by: disposeBag)
    }
}
