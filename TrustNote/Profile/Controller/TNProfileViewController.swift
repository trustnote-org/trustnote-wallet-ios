//
//  TNProfileViewController.swift
//  TrustNote
//
//  Created by zenghailongon 2018/5/24.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNProfileViewController: TNBaseViewController {
    
    let dataSource = [[["title" : "T口令", "imgName" : "command"]],
                     [["title" : "钱包工具", "imgName" : "tool"],
                     ["title" : "系统设置", "imgName" : "setting"]],
                     [["title" : "关于TrustNote", "imgName" : "about"]]
                    ] as [Any]
    fileprivate lazy var profileHeaderView: TNProfileHeaderView = {
        let profileHeaderView = TNProfileHeaderView.profileHeaderView()
        return profileHeaderView
    }()
    
    let titleLabel = UILabel().then {
        $0.text = "我的"
        $0.textColor = kTitleTextColor
        $0.font = UIFont(name: "PingFangSC-Medium", size: 20)
    }
    
    let rightItemBtn = UIButton().then {
        $0.setImage(UIImage(named: "wallet_code"), for: .normal)
    }
    
    let tableView = UITableView().then {
        $0.backgroundColor = UIColor.clear
        $0.tn_registerCell(cell: TNProfileViewCell.self)
        $0.showsVerticalScrollIndicator = false
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        tableView.delegate = self
        tableView.dataSource = self
        profileHeaderView.delegate = self
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNEditInfoCompletionNotification)).subscribe(onNext: { [unowned self] value in
            let deviceName = value.object as! String
            self.profileHeaderView.nameLabel.text = deviceName
            self.profileHeaderView.lnitialsLabel.text = deviceName.substring(toIndex: 1)
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = kBackgroundColor
    }
    
    fileprivate func setupSubviews() {
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(13 + kStatusbarH)
        }
        
        view.addSubview(rightItemBtn)
        rightItemBtn.snp.makeConstraints  {(make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.width.height.equalTo(44)
        }
        
        view.addSubview(profileHeaderView)
        profileHeaderView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview()
            make.height.equalTo(203)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(profileHeaderView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }    
}

extension TNProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionArr = dataSource[section] as! [[String: String]]
        return sectionArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TNProfileViewCell = tableView.tn_dequeueReusableCell(indexPath: indexPath)
        let sectionArr = dataSource[indexPath.section] as! [[String: String]]
        cell.rowDict = sectionArr[indexPath.row]
        cell.lineView.isHidden = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 ? true : false
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return IS_iphone5 ? 50.0 : 60.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.clear
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TNProfileViewController: TNProfileHeaderViewDelegate {
    
    func didClickedEditButton() {
        navigationController?.pushViewController(TNEditInfoController(), animated: true)
    }
    
    func didClickedManageWalletButton() {
        navigationController?.pushViewController(TNManageWalletController(), animated: true)
    }
    
    func didClickedCheckTransactionButton() {
        
    }
}
