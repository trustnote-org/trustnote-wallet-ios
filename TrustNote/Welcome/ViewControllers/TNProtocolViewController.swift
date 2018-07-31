//
//  TNProtocolViewController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/23.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import SnapKit

class TNProtocolViewController: TNNavigationController {
    
    let protocolFooterHeight = 142.0
    
    var isInit: Bool = true

    fileprivate lazy var tableView: UITableView = {[weak self] in
        
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tn_registerCell(cell: TNProtocolViewCell.self)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let lineView = UIView().then {
        $0.backgroundColor = UIColor.hexColor(rgbValue: 0xF2F2F2)
    }
    
    fileprivate lazy var footerView: TNProtocolFooterView = {
        let footerView = TNProtocolFooterView.protocolFooterView()
        return footerView
    }()
    
    fileprivate let dataSource: NSArray = ["Protocol.first", "Protocol.second", "Protocol.third", "Protocol.fourth", "Protocol.fifth", "Protocol.sixth", "Protocol.seventh", "Protocol.eighth", "Protocol.ninth", "Protocol.tenth"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        navigationBar.titleText = "Terms of Use".localized
        
        if isInit {
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 18))
            navigationBar.addSubview(lineView)
            lineView.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(1.0)
            }
        } else {
            setBackButton()
            let header = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 20))
            header.backgroundColor = UIColor.white
            tableView.tableHeaderView = header
            let footer = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 10))
            footer.backgroundColor = UIColor.white
            tableView.tableFooterView = footer
        }
        
        if isInit {
            view.addSubview(footerView)
            footerView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(-kSafeAreaBottomH)
                make.height.equalTo(protocolFooterHeight)
            }
        }
    
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(navigationBar.snp.bottom).offset(isInit ? 0 : 10)
            make.bottom.equalToSuperview().offset(-((isInit ? protocolFooterHeight : 0) + Double(kSafeAreaBottomH)))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isInit {
            view.backgroundColor = kBackgroundColor
        }
        Preferences[.launchAtFirst] = false
    }
}


extension TNProtocolViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.tn_dequeueReusableCell(indexPath: indexPath) as TNProtocolViewCell
        cell.content = dataSource[indexPath.row] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 44.0
    }
    
}
