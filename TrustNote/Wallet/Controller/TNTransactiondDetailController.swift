//
//  TNTransactiondDetailController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/23.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNTransactiondDetailController: TNNavigationController {
    
    var detailModel: TNTransactionRecord!
    
    var dataSource: [String]!
    
    var contentArr: [String] = []
    
    var rowHeightArr: [CGFloat] = []
    
    fileprivate lazy var detailHeaderview: TNTradeDetailHeaderView = {
        let detailHeaderview = TNTradeDetailHeaderView.tradeDetailHeaderView()
        return detailHeaderview
    }()
    
    let tableView = UITableView().then {
        $0.backgroundColor = UIColor.clear
        $0.tn_registerCell(cell: TNTradeDetailCell.self)
        $0.showsVerticalScrollIndicator = false
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
        $0.isScrollEnabled = false
    }
    
    init(detailModel: TNTransactionRecord) {
        super.init()
        self.detailModel = detailModel
        guard detailModel.action?.rawValue == "RECEIVED" else {
            dataSource = ["接收方","费用", "日期", "单元", "状态"]
            return
        }
        dataSource = ["发送方","接收方", "日期", "单元", "状态"]
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = kBackgroundColor
        setBackButton()
        rowHeight()
        navigationBar.backgroundColor = UIColor.clear
        detailHeaderview.detailModel = detailModel
        tableView.delegate = self
        tableView.dataSource = self
        setupUI()
    }
    
    fileprivate func setupUI() {
        view.addSubview(detailHeaderview)
        detailHeaderview.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(200)
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(detailHeaderview.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kSafeAreaBottomH)
        }
    }
}

extension TNTransactiondDetailController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TNTradeDetailCell = tableView.tn_dequeueReusableCell(indexPath: indexPath)
        cell.titleTextLabel.text = dataSource[indexPath.row]
        cell.content = contentArr[indexPath.row]
        cell.contentLabel.textAlignment = rowHeightArr[indexPath.row] > 15.0 ? .left : .right
        cell.lineView.isHidden = indexPath.row == tableView.numberOfRows(inSection: 0) - 1 ? true : false
        cell.contentLabel.textColor = indexPath.row == TNTradeDetailRow.unit.rawValue ? kGlobalColor : kTitleTextColor
        cell.statusView.isHidden = indexPath.row == TNTradeDetailRow.status.rawValue ? false : true
        if indexPath.row == TNTradeDetailRow.status.rawValue {
            var title = detailModel.confirmations ? "Confirmed".localized : "Unconfirmed".localized
            let titleColor = detailModel.confirmations ? kGlobalColor : UIColor.hexColor(rgbValue: 0xEE7A23)
            cell.statusView.setTitleColor(titleColor, for: .normal)
            var imageName = ""
            if let action = detailModel.action {
                switch action {
                case .invalid:
                    title = "Invalid".localized
                    imageName = "send_invalid"
                    cell.statusView.setTitleColor(UIColor.hexColor(rgbValue: 0xE33B1B), for: .normal)
                case .sent:
                    imageName = detailModel.confirmations ? "send_confirmed" : "send_unconfirmed"
                case .received:
                    imageName = detailModel.confirmations ? "recieve_confirmed" : "recieve_unconfirmed"
                case .move:
                    break
                }
            }
            cell.statusView.setImage(UIImage(named: imageName), for: .normal)
            cell.statusView.setTitle(title, for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (IS_iphone5 ? 44 : 50) + rowHeightArr[indexPath.row] - 15
    }
}

extension TNTransactiondDetailController {
    
    fileprivate func rowHeight() {
      
        for i in 0..<dataSource.count {
            var content = ""
            switch i {
            case TNTradeDetailRow.reciever.rawValue:
                if detailModel.action?.rawValue == "RECEIVED" {
                    if detailModel.arrPayerAddresses.count > 1 {
                        content = detailModel.arrPayerAddresses.joined(separator: ",")
                    } else {
                        content = detailModel.arrPayerAddresses.first!
                    }
                } else {
                    content = detailModel.addressTo!
                }
            case TNTradeDetailRow.fee.rawValue:
                if detailModel.action?.rawValue == "RECEIVED" {
                    content = detailModel.my_address!
                } else {
                    content =  String(format: "%.6f",  Double(detailModel.fee) / kBaseOrder) + " MN"
                }
            case TNTradeDetailRow.date.rawValue:
                let formatterDate = NSDate.getFormatterTime(timeStamp: String(detailModel.time), formatter: "yyyy/MM/dd HH:mm  ")
                let compareDate = NSDate.compareDateTime(timeStamp: detailModel.time)
                content = formatterDate + String(format:"(%@)", arguments:[compareDate])
            case TNTradeDetailRow.unit.rawValue:
                content = detailModel.unit
            case TNTradeDetailRow.status.rawValue:
                content = ""
            default:
                break
            }
            let textSize = UILabel.textSize(text: content, font: UIFont.systemFont(ofSize: 12), maxSize: CGSize(width: kScreenW - 107, height: CGFloat(MAXFLOAT)))
            contentArr.append(content)
            rowHeightArr.append(textSize.height)
        }
    }
}

