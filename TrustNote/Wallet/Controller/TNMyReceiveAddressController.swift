//
//  TNMyReceiveAddressController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/3.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class TNMyReceiveAddressController: TNNavigationController {
    
    enum MyReceiveAddressCellStyle {
        case showQRCode
        case setupAmount
        case setupCompleted
    }
    
    var wallet: TNWalletModel!
    
    let tableView = UITableView().then {
        $0.backgroundColor = UIColor.clear
        $0.tn_registerCell(cell: TNMyReceiveAddressCell.self)
        $0.tn_registerCell(cell: TNSetRecieveAmountCell.self)
        $0.showsVerticalScrollIndicator = false
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
    }
    
    var cellStyle = MyReceiveAddressCellStyle.showQRCode
    
    var amount: Int64?
    
    init(wallet: TNWalletModel) {
        super.init()
        self.wallet = wallet
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        navigationBar.backgroundColor = UIColor.hexColor(rgbValue: 0xD3DFF1)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(kLeftMargin)
            make.right.equalToSuperview().offset(-kLeftMargin)
            make.bottom.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = navigationBar.backgroundColor
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
    }
    
}

extension TNMyReceiveAddressController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if cellStyle == .setupAmount {
            let setupCell: TNSetRecieveAmountCell = tableView.tn_dequeueReusableCell(indexPath: indexPath)
            setupCell.inputTextField.becomeFirstResponder()
            setupCell.setRecieveAmountBlock = {[unowned self] (amount) in
                self.cellStyle = .setupCompleted
                self.amount = Int64(amount * 1000000)
                self.tableView.reloadData()
            }
            return setupCell
        }
        let cell: TNMyReceiveAddressCell = tableView.tn_dequeueReusableCell(indexPath: indexPath)
        if cellStyle == .setupCompleted {
            
            cell.amount = amount!
            cell.clearBtn.isHidden = false
            cell.setAmountBtn.isHidden = true
            cell.amountLabel.isHidden = false
            
            let amountStr = String(format: "%.4f", Double(amount!) / 1000000.0)
            let length = amountStr.length
            cell.amountLabel.text = amountStr.substring(toIndex: length - TNGlobalHelper.shared.unitDecimals) + "."
            let attrStr = NSMutableAttributedString(string: amountStr)
            attrStr.addAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 34)], range: NSRange(location: 0, length: length - TNGlobalHelper.shared.unitDecimals))
            attrStr.addAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 28)], range: NSRange(location: length - TNGlobalHelper.shared.unitDecimals, length: TNGlobalHelper.shared.unitDecimals))
            cell.amountLabel.attributedText = attrStr
            
            cell.clearAmountBlock = {[unowned self] in
                self.cellStyle = .showQRCode
                self.tableView.reloadData()
                cell.amount = 0
            }
        }
        if cellStyle == .showQRCode {
            cell.setupRecievedAmountBlock = {[unowned self] in
                self.cellStyle = .setupAmount
                self.tableView.reloadData()
            }
            cell.clearBtn.isHidden = true
            cell.setAmountBtn.isHidden = false
            cell.amountLabel.isHidden = true
            
        }
        cell.wallet = wallet
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let scaleH = IS_iphone5 ? 0.85 : 1.0
        if cellStyle == .setupAmount {
            return CGFloat(317.0 * scaleH)
        }
        return CGFloat(512.0 * scaleH)
    }
}
