//
//  TNSelectWalletHeaderView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/7/3.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

let selectWalletRowHeight: CGFloat = 86

let selectWalletHeaderHeight: CGFloat = 54

class TNSelectWalletCell: UITableViewCell, RegisterCellFromNib {
    
    var wallet: TNWalletModel? {
        didSet {
            walletNameLabel.text = wallet?.walletName
            let sql = "SELECT address FROM my_addresses WHERE wallet=? AND is_change=?"
            TNSQLiteManager.sharedManager.queryWalletAddress(sql: sql, walletId: wallet!.walletId, isChange: 0) {[unowned self] (results) in
                guard !results.isEmpty else {
                    return
                }
                let curAddress = results.first
                self.walletAddressLabel.text = curAddress!.substring(toIndex: addressShowCount) + "..." + curAddress!.substring(fromIndex: curAddress!.length - addressShowCount)
            }
        }
    }
    
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

class TNSelectWalletHeaderView: UIView {

    var dismissSelectListView: (() -> Void)?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismissSelectListView?()
    }
}

extension TNSelectWalletHeaderView: TNNibLoadable {
    
    class func selectWalletHeaderView() -> TNSelectWalletHeaderView {
        
        return TNSelectWalletHeaderView.loadViewFromNib()
    }
}

protocol TNSelectWalletViewDelegate: NSObjectProtocol {
    
    func dismiss()
    
    func didSelectedWallet(wallet: TNWalletModel)
}

class TNSelectWalletView: UIView {
    
    var dataSource: [TNWalletModel] = []
    
    var delegate: TNSelectWalletViewDelegate?
    
    fileprivate lazy var tableView: UITableView = {[unowned self] in
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.tn_registerCell(cell: TNSelectWalletCell.self)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    init(frame: CGRect, wallets: Array<TNWalletModel>) {
        super.init(frame: frame)
        setupRadiusCorner(radius: 2 * kCornerRadius)
        layer.masksToBounds = true
        dataSource = wallets
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TNSelectWalletView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TNSelectWalletCell = tableView.tn_dequeueReusableCell(indexPath: indexPath)
        cell.wallet = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return selectWalletRowHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         let tableHeaderView = TNSelectWalletHeaderView.selectWalletHeaderView()
        tableHeaderView.dismissSelectListView = {[unowned self] in
            self.delegate?.dismiss()
        }
        return tableHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return selectWalletHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectedWallet(wallet: dataSource[indexPath.row])
    }
}
