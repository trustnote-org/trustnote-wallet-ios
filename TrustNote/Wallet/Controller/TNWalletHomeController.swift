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
    
    var syncOperation: TNSynchroHistoryData?
    
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
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNDidFinishUpdateDatabaseNotification)).subscribe(onNext: {[unowned self] value in
            let viewModel = TNWalletBalanceViewModel()
            viewModel.queryAllWallets(completion: { (walletModels) in
                self.dataSource = walletModels
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
        
        if TNGlobalHelper.shared.isNeedLoadData {
            syncOperation = TNSynchroHistoryData()
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

extension TNWalletHomeController: TNPopCtrlCellClickDelegate {
    
    func popCtrlCellClick(tag: Int) {
        switch tag {
        case TNPopItem.scan.rawValue :
            break
        case TNPopItem.contacts.rawValue :
            break
        case TNPopItem.wallet.rawValue:
            navigationController?.pushViewController(TNCreateWalletController(), animated: true)
        case TNPopItem.code.rawValue:
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
        let profile = TNConfigFileManager.sharedInstance.readProfileFile()
        let credentials  = profile["credentials"] as! [[String:Any]]
        for dict in credentials {
            let walletModel = TNWalletModel.deserialize(from: dict)
            dataSource.append(walletModel!)
        }
        tableView.reloadData()
    }
    
    fileprivate func getWalletList() {
        totalAssert = 0.0
        let profile = TNConfigFileManager.sharedInstance.readProfileFile()
        let credentials  = profile["credentials"] as! [[String:Any]]
        for dict in credentials {
            let walletModel = TNWalletModel.deserialize(from: dict)
            totalAssert += ((walletModel?.balance)! as NSString).doubleValue
            dataSource.append(walletModel!)
        }
    }
    
    fileprivate func barBtnItemClick() {
        
        let popW: CGFloat = 154.0
        let popH: CGFloat = 44.0
        let popX = kScreenW - popW - 12.0
        let popY: CGFloat = topBar.frame.maxY + 8.0
        let imageNameArr = ["wallet_sao", "wallet_contact", "wallet_group", "wallet_code"]
        let titleArr = ["扫一扫", "添加联系人","创建钱包", "我的配对码"]
        let popView = TNPopView(frame: CGRect(x: popX, y: popY, width: popW, height: popH), imageNameArr: imageNameArr, titleArr: titleArr)
        popView.delegate = self
    }
    
    fileprivate func loadData() {
    
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.syncData()
        }
    }
    
}

extension TNWalletHomeController {
    
    fileprivate func syncData() {
        if let syncOperation = syncOperation {
            syncOperation.syncHistoryData(wallets: dataSource)
        } else {
            syncOperation = TNSynchroHistoryData()
            syncOperation?.syncHistoryData(wallets: dataSource)
        }
        
    }
}

