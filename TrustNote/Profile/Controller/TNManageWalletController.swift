//
//  TNManageWalletController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/25.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNManageWalletController: TNNavigationController {
   
    var dataSource: [TNWalletModel] = []
    var addressArr: [String] = []
    
    let titlelabel = UILabel().then {
        $0.text = "Manage wallet".localized
        $0.textColor = kTitleTextColor
        $0.font = UIFont.boldSystemFont(ofSize: 24)
    }
    
    let addBtn = UIButton().then {
        $0.setImage(UIImage(named: "profile_add_wallet"), for: .normal)
        $0.addTarget(self, action: #selector(TNManageWalletController.addWallet), for: .touchUpInside)
    }
    
    let tableView = UITableView().then {
        $0.backgroundColor = UIColor.clear
        $0.showsVerticalScrollIndicator = false
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
        $0.tn_registerCell(cell: TNManageWalletCell.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        layoutAllSubviews()
        getWalletList()
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNModifyWalletNameNotification)).subscribe(onNext: { [unowned self] value in
            self.refreshWalletList()
        }).disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNDidFinishDeleteWalletNotification)).subscribe(onNext: { [unowned self] value in
            self.refreshWalletList()
        }).disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNCreateCommonWalletNotification)).subscribe(onNext: {[unowned self] value in
            self.refreshWalletList()
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNCreateObserveWalletNotification)).subscribe(onNext: {[unowned self] value in
            self.refreshWalletList()
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = kBackgroundColor
        navigationBar.backgroundColor = kBackgroundColor
    }
}

extension TNManageWalletController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TNManageWalletCell = tableView.tn_dequeueReusableCell(indexPath: indexPath)
        cell.getFirstAddressBlock = {[unowned self] address in
            guard !self.dataSource.isEmpty && self.dataSource.count != self.addressArr.count else {
                return
            }
            self.addressArr.append(address)
        }
        cell.walletModel = dataSource[indexPath.row]
        cell.touchBtn.tag = Button_Tag_Begin + indexPath.row
        cell.checkoutWalletDetailBlock = { cellIndex in
            let vc =  TNWalletDetailController(wallet: self.dataSource[cellIndex], address: self.addressArr[cellIndex])
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
}

/// MARK: Action
extension TNManageWalletController {
    
    @objc fileprivate func addWallet() {
        navigationController?.pushViewController(TNCreateWalletController(), animated: true)
    }
    
    fileprivate func refreshWalletList() {
       dataSource.removeAll()
       getWalletList()
      tableView.reloadData()
    }
}

/// MARK: Custom Methods
extension TNManageWalletController {
    
    fileprivate func getWalletList() {
        let profile = TNConfigFileManager.sharedInstance.readProfileFile()
        let credentials  = profile["credentials"] as! [[String:Any]]
        for dict in credentials {
            let walletModel = TNWalletModel.deserialize(from: dict)
            dataSource.append(walletModel!)
        }
    }
}

/// Setup Subviews
extension TNManageWalletController {
    
    fileprivate func layoutAllSubviews() {
        view.addSubview(titlelabel)
        titlelabel.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom).offset(9)
            make.left.equalToSuperview().offset(kLeftMargin)
        }
        
        view.addSubview(addBtn)
        addBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.width.height.equalTo(60)
            make.centerY.equalTo(titlelabel.snp.centerY)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(titlelabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kSafeAreaBottomH)
        }
    }
}
