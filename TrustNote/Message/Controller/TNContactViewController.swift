//
//  TNContactViewController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/25.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNContactViewController: TNBaseViewController {
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
    }

}

/// MARK: action
extension TNContactViewController {
    
    @IBAction func popAction(_ sender: Any) {
        let popW: CGFloat = 154.0
        let popH: CGFloat = 44.0
        let popX = kScreenW - popW - 12.0
        let popY: CGFloat = topBar.frame.maxY - 22
        let imageNameArr = ["wallet_sao", "wallet_contact", "wallet_group", "wallet_code"]
        let titleArr = ["扫一扫", "添加联系人","创建钱包", "我的配对码"]
        let popView = TNPopView(frame: CGRect(x: popX, y: popY, width: popW, height: popH), imageNameArr: imageNameArr, titleArr: titleArr)
         popView.delegate = self
    }
}

extension TNContactViewController: TNPopCtrlCellClickDelegate {
    
    func popCtrlCellClick(tag: Int) {
        switch tag {
        case TNPopItem.scan.rawValue :
            break
        case TNPopItem.contacts.rawValue :
            break
        case TNPopItem.wallet.rawValue:
            navigationController?.pushViewController(TNCreateWalletController(), animated: true)
        case TNPopItem.code.rawValue:
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
