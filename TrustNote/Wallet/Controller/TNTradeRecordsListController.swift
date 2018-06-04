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
    
    init(wallet: TNWalletModel) {
        super.init()
        self.wallet = wallet
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct Reusable {
        static let transactionRecordCell = ReusableCell<TNTradeRecordCell>(nibName: "TNTradeRecordCell")
    }
    
    var dataSource: RxTableViewSectionedReloadDataSource<TNRecordSection>!
    
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
        $0.register(Reusable.transactionRecordCell)
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
        bindView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
}

extension TNTradeRecordsListController {
    
    fileprivate func bindView() {
        dataSource = RxTableViewSectionedReloadDataSource<TNRecordSection>(configureCell: { (ds, tv, ip, item) -> TNTradeRecordCell in
            let cell = tv.dequeue(Reusable.transactionRecordCell, for: ip)
            cell.model = item
            return cell
        })
        
        // setup delegate
        tableView.rx.setDelegate(self).disposed(by: self.disposeBag)
        
        tableView.rx.itemSelected.map { indexPath in
            return (indexPath,self.dataSource[indexPath])
            }
            .subscribe(onNext: { indexPath, model in
                let detailController = TNTransactiondDetailController(detailModel: model)
                self.navigationController?.pushViewController(detailController, animated: true)
            })
            .disposed(by: self.disposeBag)
        
        viewModel.getTransactionRecords(wallet.walletId)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
    }
    
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
}

extension TNTradeRecordsListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
