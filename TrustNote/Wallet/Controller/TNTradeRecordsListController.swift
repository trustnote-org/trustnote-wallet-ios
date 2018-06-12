//
//  TNTradeRecordsListController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/20.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import ReusableKit
import RxDataSources
import RxCocoa
import RxSwift
import IQKeyboardManagerSwift

class TNTradeRecordsListController: TNNavigationController {
    
    var wallet: TNWalletModel!
    
    let viewModel = TNTradeRecordViewModel()
    
    var dataSource: [TNTransactionRecord] = []
    
    init(wallet: TNWalletModel) {
        super.init()
        self.wallet = wallet
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var tradeRecordHeaderview: TNTradeRecordHeaderview = {
        let tradeRecordHeaderview = TNTradeRecordHeaderview.tradeRecordHeaderview()
        return tradeRecordHeaderview
    }()
    
    fileprivate lazy var switchView: TNTradeRecordSwitchView = {
        let switchView = TNTradeRecordSwitchView.recordSwitchView()
        return switchView
    }()
    
    let tableView = UITableView().then {
        $0.backgroundColor = UIColor.clear
        $0.tn_registerCell(cell: TNTradeRecordCell.self)
        $0.showsVerticalScrollIndicator = false
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        view.backgroundColor = kBackgroundColor
        tradeRecordHeaderview.walletModel = wallet
        switchView.receivingTransferrinrBlock = {[unowned self] in
            let vc = TNMyReceiveAddressController(wallet: self.wallet)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        switchView.transferAccountBlock = {[unowned self] in
            let vc = TNSendViewController(wallet: self.wallet)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        updateData()
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNTransferSendSuccessNotify)).subscribe(onNext: {[unowned self] value in
            self.updateData()
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
}

extension TNTradeRecordsListController {
    
    fileprivate func setupUI() {
        view.addSubview(tradeRecordHeaderview)
        tradeRecordHeaderview.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(180)
        }
        
        view.addSubview(switchView)
        switchView.snp.makeConstraints { (make) in
            make.top.equalTo(tradeRecordHeaderview.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(70)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(switchView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kSafeAreaBottomH)
        }
    }
    
    fileprivate func updateData() {
       
        viewModel.queryTransactionRecordList(walletId: wallet.walletId) {[unowned self] (records) in
            self.dataSource = records
            self.tableView.reloadData()
        }
    }
}

extension TNTradeRecordsListController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TNTradeRecordCell = tableView.tn_dequeueReusableCell(indexPath: indexPath)
        cell.model = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = TNTransactiondDetailController(detailModel: dataSource[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let tableHeaderView = UIView()
        tableHeaderView.backgroundColor = kBackgroundColor
        tableHeaderView.frame = CGRect(x: 0, y: 0, width: kScreenW, height: 42)
        let titleLabel = UILabel()
        titleLabel.text = "Recent transaction records".localized
        titleLabel.textColor = UIColor.hexColor(rgbValue: 0x666666)
        titleLabel.font = UIFont.systemFont(ofSize: 14.0)
        titleLabel.sizeToFit()
        titleLabel.x = CGFloat(kLeftMargin)
        titleLabel.centerY = tableHeaderView.height * 0.5
        tableHeaderView.addSubview(titleLabel)
        return tableHeaderView
    }
    
}
