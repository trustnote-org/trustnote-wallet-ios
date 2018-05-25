//
//  TNProtocolViewController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/23.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import SnapKit

class TNProtocolViewController: TNBaseViewController {

    fileprivate lazy var tableView: UITableView = {[weak self] in
        
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tn_registerCell(cell: TNProtocolViewCell.self)
        tableView.separatorStyle = .none
        tableView.tableHeaderView = TNProtocolHeaderView.protocolHeaderView()
        tableView.tableHeaderView?.height = 54.0
        tableView.tableFooterView = TNProtocolFooterView.protocolFooterView()
        tableView.tableFooterView?.height = 150
        return tableView
        }()
    
    fileprivate let dataSource: NSArray = ["Protocol.first", "Protocol.second", "Protocol.third", "Protocol.fourth", "Protocol.fifth", "Protocol.sixth", "Protocol.seventh", "Protocol.eighth", "Protocol.ninth", "Protocol.tenth", "Protocol.eleventh"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(kStatusbarH, 0, 0, 0))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
