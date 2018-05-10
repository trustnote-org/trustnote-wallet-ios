//
//  TNWalletViewController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/3.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import ReusableKit
import RxDataSources
import RxCocoa
import RxSwift

class TNWalletViewController: TNBaseViewController {
   
    let viewModel = TNTradeRecordViewModel()
    
    struct Reusable {
        static let transactionRecordCell = ReusableCell<TNTransactionRecordCell>(nibName: "TNTransactionRecordCell")
    }
    
    let tableView = UITableView().then {
        $0.backgroundColor = UIColor.clear
        $0.register(Reusable.transactionRecordCell)
        $0.showsVerticalScrollIndicator = false
        $0.tableHeaderView = UIView()
    }
    
    var dataSource: RxTableViewSectionedReloadDataSource<TNRecordSection>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindView()
    }
}

extension TNWalletViewController {
    
    fileprivate func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(view.snp.top).offset(20);
        }
    }
    
    fileprivate func bindView() {
        dataSource = RxTableViewSectionedReloadDataSource<TNRecordSection>(configureCell: { (ds, tv, ip, item) -> TNTransactionRecordCell in
            let cell = tv.dequeue(Reusable.transactionRecordCell, for: ip)
            cell.model = item
            return cell
        })
        
        // setup delegate
        tableView.rx.setDelegate(self).disposed(by: self.disposeBag)

        viewModel.getTransactionRecords()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
    }
}
    
extension TNWalletViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let transaction = viewModel.transactionRecords![indexPath.row]
        return transaction.action == .received ? 70 : 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


