//
//  TNContactAddressController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/12.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNContactAddressController: TNNavigationController {
    
    var addressList: [[String: String]] = []
    
    var wallet: TNWalletModel!
    
    var selectAddressCompletion: ((String) -> Void)!
    
    fileprivate lazy var headerView: TNContactAddressHeadView = {
        let headerView = TNContactAddressHeadView.contactAddressHeadView()
        return headerView
    }()
    
    fileprivate lazy var noContactView: TNNoContactAddressView = {
        let noContactView = TNNoContactAddressView.noContactAddressView()
        return noContactView
    }()
    
    let tableView = UITableView().then {
        $0.backgroundColor = UIColor.clear
        $0.tn_registerCell(cell: TNContactAddressCell.self)
        $0.showsVerticalScrollIndicator = false
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
    }
    
    init(wallet: TNWalletModel, completion: @escaping (String) -> Void) {
        self.selectAddressCompletion = completion
        self.wallet = wallet
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setupSubviews()
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 10))
        tableHeaderView.backgroundColor = UIColor.clear
        tableView.tableHeaderView = tableHeaderView
        tableView.delegate = self
        tableView.dataSource = self
        
        if !TNConfigFileManager.sharedInstance.isExistAddressFile() {
            noContactView.isHidden = false
        } else {
            let addressDict = TNConfigFileManager.sharedInstance.readAddressFile()
            addressList = addressDict["addressList"] as! [[String: String]]
           // addressList = addressDict[wallet.walletId] as! [[String: String]]
            reloadListView()
        }
        headerView.addContactAddressBlock = {[unowned self] in
            self.handleAddAddressCompletion()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = kBackgroundColor
    }
}

extension TNContactAddressController {
    
    fileprivate func handleAddAddressCompletion() {
        
        let vc = TNEditAddressController(titleText: "Add address".localized) {[unowned self] (address, remarks) in
            
            let addressItem = ["address": address, "remarks": remarks]
            self.addressList.append(addressItem)
            self.reloadListView()
            if !TNConfigFileManager.sharedInstance.isExistAddressFile() {
                let data = ["addressList": [addressItem]]
                TNConfigFileManager.sharedInstance.saveDataToAddress(data as NSDictionary)
            } else {
                let dict = TNConfigFileManager.sharedInstance.readAddressFile() as! [String: Any]
                var addressItems = dict["addressList"] as! [[String: String]]
                addressItems.append(addressItem)
                TNConfigFileManager.sharedInstance.updateAddress(key: "addressList", value: addressItems)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func reloadListView() {
        noContactView.isHidden = addressList.isEmpty ? false : true
        tableView.reloadData()
    }
    
    fileprivate func deleteRow(indexPath: IndexPath) {
        addressList.remove(at: indexPath.row)
        reloadListView()
        let dict = TNConfigFileManager.sharedInstance.readAddressFile() as! [String: Any]
        var addressItems = dict["addressList"] as! [[String: String]]
        addressItems.remove(at: indexPath.row)
        TNConfigFileManager.sharedInstance.updateAddress(key: "addressList", value: addressItems)
    }
    
    fileprivate func editRow(indexPath: IndexPath) {
        let vc = TNEditAddressController(titleText: "Edit address".localized) {[unowned self] (address, remarks) in
            
            let addressItem = ["address": address, "remarks": remarks]
            self.addressList[indexPath.row] = addressItem
            self.reloadListView()
            let dict = TNConfigFileManager.sharedInstance.readAddressFile() as! [String: Any]
            var addressItems = dict["addressList"] as! [[String: String]]
            addressItems[indexPath.row] = addressItem
            TNConfigFileManager.sharedInstance.updateAddress(key: "addressList", value: addressItems)
        }
        vc.addressItem = addressList[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension TNContactAddressController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TNContactAddressCell = tableView.tn_dequeueReusableCell(indexPath: indexPath)
        cell.content = addressList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let addressItem = addressList[indexPath.row]
        selectAddressCompletion(addressItem["address"]!)
        navigationController?.popViewController(animated: true)
    }
    
    private func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [AnyObject]? {
        
        let editAction = UITableViewRowAction(style: .normal, image: UIImage(named: "address_edit")) {[unowned self] (action, index) in
            self.editRow(indexPath: indexPath)
        }
        editAction.backgroundColor = UIColor.hexColor(rgbValue: 0x539AFF)
        
        let deleteAction = UITableViewRowAction(style: .normal, image: UIImage(named: "address_delete")) {[unowned self] (action, index) in
            self.deleteRow(indexPath: indexPath)
        }
        deleteAction.backgroundColor = UIColor.hexColor(rgbValue: 0xE33B1B)
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: nil) {[unowned self] (action, sourceView, completionHandler) in
            self.editRow(indexPath: indexPath)
            completionHandler(true)
        }
        editAction.image = UIImage(named: "address_edit")
        editAction.backgroundColor = UIColor.hexColor(rgbValue: 0x539AFF)
        
        let deleteAction = UIContextualAction(style: .normal, title: nil) {[unowned self] (action, sourceView, completionHandler) in
            self.deleteRow(indexPath: indexPath)
            completionHandler(true)
        }
        deleteAction.image = UIImage(named: "address_delete")
        deleteAction.backgroundColor = UIColor.hexColor(rgbValue: 0xE33B1B)
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return config
    }
}

extension TNContactAddressController {
    
    fileprivate func setupSubviews() {
        view.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(64)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kSafeAreaBottomH)
        }
        
        view.addSubview(noContactView)
        noContactView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
