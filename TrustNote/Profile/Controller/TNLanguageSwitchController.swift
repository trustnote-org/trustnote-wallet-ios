//
//  TNLanguageSwitchController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/28.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNLanguageSwitchController: TNNavigationController {
    
    var selectedItem: Int!
    
    let tableView = UITableView().then {
        $0.backgroundColor = UIColor.clear
        $0.showsVerticalScrollIndicator = false
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
        $0.tn_registerCell(cell: TNLanguageSelectwCell.self)
    }
    
    init(selectedItem: Int) {
        super.init()
        self.selectedItem = selectedItem
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        navigationBar.titleText = "Language".localized
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 10))
        tableHeaderView.backgroundColor = UIColor.clear
        tableView.tableHeaderView = tableHeaderView
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = kBackgroundColor
    }
}

extension TNLanguageSwitchController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TNLanguageSelectwCell = tableView.tn_dequeueReusableCell(indexPath: indexPath)
        if indexPath.row == 0 {
            cell.titleLabel.text = "English"
            cell.lineView.isHidden = false
        } else {
            cell.titleLabel.text = "中文"
            cell.lineView.isHidden = true
        }
        cell.selectedImageView.isHidden = selectedItem == indexPath.row ? false : true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectedItem != indexPath.row {
            selectedItem = indexPath.row
            tableView.reloadData()
            var language = ""
            if indexPath.row == 0 {
                language = "en"
            } else {
                language = "zh-Hans"
            }
            TNLocalizationTool.shared.setLanguage(langeuage: language)
            let view = UIApplication.shared.delegate?.window as? UIView
            let hud = MBProgress_TNExtension.showHUDAddedToView(view: view!, title: "正在设置语言...", animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                hud.removeFromSuperview()
                let delegate = UIApplication.shared.delegate as! AppDelegate
                delegate.resetRootViewController()
            }
        }
    }
}
