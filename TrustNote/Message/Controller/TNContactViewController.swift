//
//  TNContactViewController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/25.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNContactViewController: TNBaseViewController {
    
    var dataSource: [String] = ["1", "2", "3", "4", "5"]
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var topBarheightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topBarheightConstraint.constant = IS_iPhoneX ? 118 : 94
        detailLabel.text = "NoContactsDesc".localized
        configTableView()
        if !dataSource.isEmpty {
            containerView.isHidden = true
        }
        topBar.setupShadow(Offset: CGSize(width: 0, height: 5), opacity: 0, radius: 5)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = kBackgroundColor
    }
    
    fileprivate func configTableView() {
        tableView.tn_registerCell(cell: TNContactCell.self)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension TNContactViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TNContactCell = tableView.tn_dequeueReusableCell(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(TNChatViewController(), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y > 0 {
            topBar.layer.shadowOpacity = 0.1
        } else {
            topBar.layer.shadowOpacity = 0
        }
    }
}

/// MARK: action
extension TNContactViewController {
    
    @IBAction func popAction(_ sender: Any) {
        let popW: CGFloat = TNLocalizationTool.shared.currentLanguage == "en" ? 174 : 154
        let popH: CGFloat = 44.0
        let popX = kScreenW - popW - 12.0
        let popY: CGFloat = topBar.frame.maxY - 22
        let imageNameArr = ["wallet_sao", "wallet_contact", "wallet_group", "wallet_code"]
        let titleArr = ["Scan QR Code".localized, "Add Contact".localized,"Create Wallet".localized, "My Matching Code".localized]
        let popView = TNPopView(frame: CGRect(x: popX, y: popY, width: popW, height: popH), imageNameArr: imageNameArr, titleArr: titleArr)
        popView.delegate = self
    }
}


extension TNContactViewController: TNPopCtrlCellClickDelegate {
    
    func popCtrlCellClick(tag: Int) {
        switch tag {
        case TNPopItem.scan.rawValue :
            break
        case TNPopItem.addContacts.rawValue :
            navigationController?.pushViewController(TNAddContactsController(), animated: true)
        case TNPopItem.createWallet.rawValue:
            navigationController?.pushViewController(TNCreateWalletController(), animated: true)
        case TNPopItem.MatchingCode.rawValue:
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
        default:
            break
        }
    }
}
