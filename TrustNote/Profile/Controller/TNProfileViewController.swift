//
//  TNProfileViewController.swift
//  TrustNote
//
//  Created by zenghailongon 2018/5/24.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNProfileViewController: TNBaseViewController {
    
    let dataSource = [[["title" : "T口令", "imgName" : "command", "action" : ""]],
                     [["title" : "Wallet tools".localized, "imgName" : "tool", "action" : "enterIntoWalletTool"],
                     ["title" : "Settings".localized, "imgName" : "setting", "action" : "enterIntoSetting"]],
                     [["title" : "About trustNote".localized, "imgName" : "about", "action" : "aboutTrustNote"]]
                    ] as [Any]
    fileprivate lazy var profileHeaderView: TNProfileHeaderView = {
        let profileHeaderView = TNProfileHeaderView.profileHeaderView()
        return profileHeaderView
    }()
    
    let titleLabel = UILabel().then {
        $0.text = "Profile".localized
        $0.textColor = kTitleTextColor
        $0.font = UIFont(name: "PingFangSC-Medium", size: 20)
    }
    
    let rightItemBtn = UIButton().then {
        $0.setImage(UIImage(named: "wallet_code"), for: .normal)
        $0.addTarget(self, action: #selector(TNProfileViewController.checkMyDeviceCode), for: .touchUpInside)
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
        let sectionArr = dataSource[indexPath.section] as! [[String: String]]
        let rowDict = sectionArr[indexPath.row]
        let action = rowDict["action"]
        guard !(action?.isEmpty)! else {
            return
        }
        let control: UIControl = UIControl()
        control.sendAction(Selector(action!), to: self, for: nil)
    }
}

extension TNProfileViewController: TNProfileHeaderViewDelegate {
    
    func didClickedEditButton() {
        navigationController?.pushViewController(TNEditInfoController(isEditInfo: true), animated: true)
    }
    
    func didClickedManageWalletButton() {
        navigationController?.pushViewController(TNManageWalletController(), animated: true)
    }
    
    func didClickedCheckTransactionButton() {
        
    }
}

extension TNProfileViewController {
    
    @objc fileprivate func checkMyDeviceCode() {
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
    
    @objc fileprivate func enterIntoWalletTool() {
        
        let dataArr = [
            [["title" : "Backup Your Seed Phrase".localized, "detail" : "", "action" : "backupTheMnemonic", "isCanSelected" : true],
                         ["title" : "Restore from the mnemonic".localized, "detail" : "", "action" : "restoreWalletFromMnemonic", "isCanSelected" : true]],
                        [["title" : "Sync from cloned wallet".localized, "detail" : "", "action" : "syncFromClonedWallet", "isCanSelected" : true]]
                      ] as [Any]
        let vc = TNGeneralViewController(dataSource: dataArr, titleText: TNLocalizationTool.shared.valueWithKey(key: "Wallet tools"))
        navigationController?.pushViewController(vc, animated: true)
    }
   
    @objc  func enterIntoSetting() {
        
        var language = ""
        if TNLocalizationTool.shared.currentLanguage == "zh-Hans" {
            language = "简体中文"
        } else {
            language = "English"
        }
        let dataArr = [
            [["title" : "Language".localized, "detail" : language, "action" : "switchLanguage", "isCanSelected" : true],
             ["title" : "Wallet password".localized, "detail" : "", "action" : "setupWalletPassword", "isCanSelected" : true]]
            ] as [Any]
        let vc = TNGeneralViewController(dataSource: dataArr, titleText: "Settings".localized)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func aboutTrustNote() {
        
        let infoDict = Bundle.main.infoDictionary
        let gitSHA = "#" + (infoDict!["GitCommitSHA"] as! String)
        let dataArr = [
            [["title" : "Version".localized, "detail" : "V2.0.0 light", "action" : "", "isCanSelected" : false],
             ["title" : "Hash value".localized, "detail" : gitSHA, "action" : "", "isCanSelected" : false],
             ["title" : "Terms of Use".localized, "detail" : "", "action" : "", "isCanSelected" : true]]
            ] as [Any]
        let vc = TNGeneralViewController(dataSource: dataArr, titleText: "About trustNote".localized)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension TNProfileViewController {
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
