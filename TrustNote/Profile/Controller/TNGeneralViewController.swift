//
//  TNGeneralViewController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/28.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNGeneralViewController: TNNavigationController {
    
    var dataSource: [Any] = []
    var titleText = ""
    
    let titleView = UIView().then {
        $0.backgroundColor = UIColor.white
    }
    
    let titlelabel = UILabel().then {
        $0.textColor = kTitleTextColor
        $0.font = kTitleFont
    }
    
    let tableView = UITableView().then {
        $0.backgroundColor = UIColor.clear
        $0.showsVerticalScrollIndicator = false
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
        $0.tn_registerCell(cell: TNProfileGeneralCell.self)
    }
    
    init(dataSource: [Any], titleText: String) {
        super.init()
        self.dataSource = dataSource
        self.titleText = titleText
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        titlelabel.text = titleText
        layoutAllSubviews()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = kBackgroundColor
    }
}

extension TNGeneralViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionArr = dataSource[section] as! [[String: Any]]
        return sectionArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TNProfileGeneralCell = tableView.tn_dequeueReusableCell(indexPath: indexPath)
        let sectionArr = dataSource[indexPath.section] as! [[String: Any]]
        cell.rowDict = sectionArr[indexPath.row]
        cell.lineView.isHidden = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 ? true : false
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.clear
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section == 0 else {
            return 10
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionArr = dataSource[indexPath.section] as! [[String: Any]]
        let rowDict = sectionArr[indexPath.row]
        let action = rowDict["action"] as! String
        guard !action.isEmpty else {
            return
        }
        let control: UIControl = UIControl()
        control.sendAction(Selector(action), to: self, for: nil)
    }
}

extension TNGeneralViewController {
    
    @objc fileprivate func switchLanguage () {
        let language = TNLocalizationTool.shared.defaults.object(forKey: "langeuage") as! String
        var selectedItem: Int?
        if language == "zh-Hans" {
           selectedItem = 1
        } else {
            selectedItem = 0
        }
        let vc = TNLanguageSwitchController(selectedItem: selectedItem!)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func syncFromClonedWallet() {
        let vc = TNCloneWalletController(nibName: "\(TNCloneWalletController.self)", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func restoreWalletFromMnemonic() {
        navigationController?.pushViewController(TNRecoveryWalletController(), animated: true)
    }
    
    @objc fileprivate func backupTheMnemonic() {
        navigationController?.pushViewController(TNProfileBackupController(), animated: true)
    }
    
    @objc fileprivate func setupWalletPassword() {
        navigationController?.pushViewController(TNModifyPasswordController(), animated: true)
    }
}

/// Setup Subviews
extension TNGeneralViewController {
    
    fileprivate func layoutAllSubviews() {
        
        view.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(63)
        }
        
        titleView.addSubview(titlelabel)
        titlelabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(9)
            make.left.equalToSuperview().offset(kLeftMargin)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(titleView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kSafeAreaBottomH)
        }
    }
}
