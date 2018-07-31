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
        static let walletCell = "\(TNWalletCell.self)"
    }
    let walletCellHeight: CGFloat = 86.0
    let totalAssertHeight: CGFloat = 140.0
    let topBarHeight: CGFloat = 44.0
    let tableViewHeight: CGFloat = kScreenH - kSafeAreaBottomH - 44 - kStatusbarH
    
    var dataSource: [TNWalletModel] = []
    let reachability = Reachability()!
    var isReachable: Bool = true
    var totalAssert = 0.0
    var selectWalletListView: TNCustomAlertView?
    var syncOperation = TNSyncWalletData()
    var scanningResult: String?
    
    let totalAssertView: TNTotalAssertView = TNTotalAssertView .totalAssertView()
    
    private let tableView = UITableView().then {
        $0.backgroundColor = UIColor.clear
        $0.register(UINib(nibName: Reusable.walletCell, bundle: nil), forCellReuseIdentifier: Reusable.walletCell)
        $0.separatorStyle = .none
        $0.tableFooterView = UIView()
        $0.showsVerticalScrollIndicator = false
    }
    
    fileprivate lazy var topBar: TNWalletTopBar = {
        let topBarView = TNWalletTopBar.walletTopBar()
        return topBarView
    }()
    
    fileprivate lazy var networkStatus: TNNetworkStatusView = {
        let networkStatus = TNNetworkStatusView.networkStatusView()
        return networkStatus
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = kBackgroundColor
        setStatusBarBackgroundColor(color: UIColor.white)
        if TNGlobalHelper.shared.isVerifyPasswdForMain {
            let vc = TNVerifyPasswordController()
            navigationController?.present(vc, animated: false) {
                TNGlobalHelper.shared.mnemonic = ""
                vc.passwordAlertView.passwordTextField.becomeFirstResponder()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setStatusBarBackgroundColor(color: UIColor.clear)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // observeNetworkStatus()
        getWalletList()
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        setupUI()
        setRefreshHeader()
        setupTableViewFooterView()
        topBar.clickedAddButtonBlock = {[unowned self] in
            self.barBtnItemClick()
        }
        
        registerNotification()
        
        syncOperation.syncWalletDataComlpetion = {[weak self] in
            self?.endRefresing()
        }
        
        loadData()
    }
    
    fileprivate func setupUI() {
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kStatusbarH)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    fileprivate func setupTableViewFooterView() {
       
        let footerHeight = tableViewHeight - (topBarHeight + totalAssertHeight) - CGFloat(dataSource.count) * walletCellHeight
        if footerHeight > 0 {
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: footerHeight))
            footerView.backgroundColor = UIColor.white
            tableView.tableFooterView = footerView
        } else {
            tableView.tableFooterView = UIView()
       }
    }
    
    deinit {
        reachability.stopNotifier()
    }
}

extension TNWalletHomeController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: Reusable.walletCell) as! TNWalletCell
        cell.model = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
        return walletCellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        headerView.addSubview(topBar)
        topBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        headerView.addSubview(totalAssertView)
        totalAssertView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(topBar.snp.bottom)
        }
        totalAssertView.totalAssert = totalAssert
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return topBarHeight + totalAssertHeight
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
    
    fileprivate func setRefreshHeader() {
        
        tableView.gtm_addRefreshHeaderView(refreshHeader: TNRefreshHeader()) {
            [weak self] in
            self?.pullTorefresh()
        }
    }
    
    func pullTorefresh() {
        if syncOperation.isLoading {
            endRefresing()
            return
        }

        syncData(true)
    }
    
    func endRefresing() {
        tableView.endRefreshing(isSuccess: true)
    }
    
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
        self.setupTableViewFooterView()
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
        let popY: CGFloat = topBar.frame.maxY + kStatusbarH + 8.0
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
                self.syncData(false)
            }
        } else {
            TNWebSocketManager.sharedInstance.socketDidConnectedBlock = {[unowned self] in
                self.syncData(false)
                TNWebSocketManager.sharedInstance.socketDidConnectedBlock = nil
            }
        }
    }
}

extension TNWalletHomeController {
    
    public func syncData(_ isRefresh: Bool) {
        syncOperation.isRefresh = isRefresh
        syncOperation.syncWalletsData(wallets: dataSource)
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
                self.setupTableViewFooterView()
            })
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNCreateCommonWalletNotification)).subscribe(onNext: {[unowned self] value in
            self.refreshAction()
        }).disposed(by: disposeBag)
        
   NotificationCenter.default.rx.notification(Notification.Name.UIApplicationWillEnterForeground).subscribe(onNext: {[unowned self] value in
            self.pullTorefresh()
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
