//
//  TNChatViewController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/15.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import SnapKit

class TNChatViewController: TNNavigationController {
    
    let kTitleViewHeight: CGFloat = 50.0
    
    var containerViewHeight: CGFloat!
    
    let inputMaxRows = 4
    
    var messages: [TNChatMessageModel] = []
    
    var bottomInputView: TNChatInputView?
    
    var deviceAddress: String!
    
    var correspondentDevice: TNCorrespondentDevice!
    
    var isFirst = true
    
    var keyboardH: CGFloat = 0
    
    private let textLabel = UILabel().then {
        $0.textColor = kTitleTextColor
        $0.font = kTitleFont
        $0.text = "Cocoa"
    }
    
    private let titleView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.setupShadow(Offset: CGSize(width: 0, height: 5), opacity: 0, radius: 5)
    }
    
    private let containerView = UIView()
    
    private let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.backgroundColor = UIColor.clear
        $0.tableFooterView = UIView()
    }
    
    init(device: String) {
        super.init()
        self.deviceAddress = device
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerViewHeight =  kScreenH - kTitleViewHeight - kSafeAreaBottomH - kNavBarHeight
        setBackButton()
        _ = navigationBar.setRightButtonImage(imageName: "message_menu", target: self, action: #selector(self.popChatMenu))
        setupUI()
        setupContainerView()
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        getMessageList()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.recieveNewMessage), name: NSNotification.Name(rawValue: TNDidRecievedMessageNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.recieveConfirmedNotification), name: NSNotification.Name(rawValue: TNAddContactConfirmedNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.recieveRemovedMessage), name: NSNotification.Name(rawValue: TNDidRecievedRemovedNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.recieveConfirmedNotification), name: NSNotification.Name(rawValue: TNDidSetAliasSuccessNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var  navigationArray = navigationController?.viewControllers
        if navigationArray?.count == 3 {
            for (index, vc) in navigationArray!.enumerated() {
                if vc.isKind(of: TNAddContactsController.self) {
                    navigationArray?.remove(at: index)
                }
            }
            navigationController?.viewControllers = navigationArray!
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isFirst {
            autoRollToLastRow(animated: false)
            isFirst = false
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension  TNChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return TNChatCell.cellWithTableView(tableView, messageModel: messages[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TNChatCell.cellHeightWith(messageModel: messages[indexPath.row])
    }
    
}

extension TNChatViewController {
    
    fileprivate func compareDate(newFormatterDate: String) -> Bool {
        if messages.isEmpty {
            return true
        }
        let lastFormatterDate = messages.last?.messageTime
        let date1 = TNChatDate.getDateFromFormatterTime(lastFormatterDate!)
        let date2 = TNChatDate.getDateFromFormatterTime(newFormatterDate)
        return TNChatDate.isNeedShowTime(date1: date1, date2: date2)
    }
    
    fileprivate func autoRollToLastRow(animated: Bool)  {
        
        tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: animated)
    }
    
    fileprivate func getMessageList() {
        
        TNSQLiteManager.sharedManager.queryContact(deviceAddress: deviceAddress) {[unowned self] (correspondent) in
            self.correspondentDevice = correspondent
            self.textLabel.text = correspondent.name
        }
        
        TNSQLiteManager.sharedManager.queryChatMessages(deviceAddress: deviceAddress) {[unowned self] (messageModels) in
            let sortArr = TNChatDate.sortResult(sortedArray: messageModels)
            self.messages =  TNChatDate.computeVisibleTime(dataArray: sortArr)
            self.tableView.reloadData()
        }
    }
}

extension TNChatViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y > 0 {
            titleView.layer.shadowOpacity = 0.1
        } else {
            titleView.layer.shadowOpacity = 0
        }
    }
}

extension TNChatViewController: TNPopCtrlCellClickDelegate {
    
    func popCtrlCellClick(tag: Int) {
        switch tag {
        case TNPopItem.setRemarks.rawValue - 4 :
            navigationController?.pushViewController(TNModifyRemarkController(correspondent: correspondentDevice), animated: true)
        case TNPopItem.deleteContact.rawValue - 4 :
            removeCurrentContact()
        case TNPopItem.clearMessage.rawValue - 4:
            removeCurrentContactChatRecords()
        default:
            break
        }
    }
}

extension TNChatViewController: TNChatInputVieDelegate {
    
    func chatKeyboardWillShow(keyBoardHeight: CGFloat, duration: TimeInterval) {
        keyboardH = keyBoardHeight
        autoRollToLastRow(animated: true)
        let moveH = getTableMoveHeight()
        UIView.animate(withDuration: duration) {
            self.tableView.y = -moveH
            self.bottomInputView!.y = self.containerViewHeight - self.bottomInputView!.textInputRect.size.height - keyBoardHeight
            self.titleView.layer.shadowOpacity = 0.1
        }
    }
    
    func chatKeyboardWillHide(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.tableView.y = 0
            self.bottomInputView!.y = self.containerViewHeight - self.bottomInputView!.textInputRect.size.height
            if self.tableView.contentOffset.y == 0 {
                self.titleView.layer.shadowOpacity = 0
            }
        }
    }
    
    func sendMessage(text: String) {
        
        let createDate = NSDate.getCurrentFormatterTime()
        var messageModel = TNChatMessageModel()
        messageModel.messageText = text
        messageModel.messageTime = createDate
        messageModel.messeageType = .text
        messageModel.senderType = .oneself
        if compareDate(newFormatterDate: createDate) {
            messageModel.isShowTime = true
            messageModel.showTime = TNChatDate.showTimeFormatter(createDate)
        }
        messages.append(messageModel)
        
        updateTableView()
        let moveH = getTableMoveHeight()
        UIView.animate(withDuration: 0.2) {
            self.tableView.y = -moveH
        }
        
        DispatchQueue.global().async {
            TNChatManager.sendTextMessage(pubkey: self.correspondentDevice.pubkey, hub: self.correspondentDevice.hub, text: text)
        }
        TNSQLiteManager.sharedManager.updateChatMessagesTable(address: deviceAddress, message: text, date: createDate, isIncoming: 0, type: TNMessageType.text.rawValue)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: TNSendMessageToOtherNotification), object: deviceAddress)
        
    }
}

extension TNChatViewController {
    
    @objc fileprivate func popChatMenu() {
        let popW: CGFloat = TNLocalizationTool.shared.currentLanguage == "en" ? 194 : 174
        let popH: CGFloat = popRowHeight
        let popX = kScreenW - popW - popRightMargin 
        let popY: CGFloat = navigationBar.frame.maxY + 8.0
        let imageNameArr = ["message_edit", "message_delete", "message_clear"]
        let titleArr = ["Set Alias".localized, "Delete Contact".localized, "Clear Chat History".localized]
        let popView = TNPopView(frame: CGRect(x: popX, y: popY, width: popW, height: popH), imageNameArr: imageNameArr, titleArr: titleArr)
        popView.delegate = self
    }
    
    @objc fileprivate func recieveNewMessage(notify: Notification) {
        let object = notify.object as! [String: Any]
        let messageObj = object["messageObj"] as! [String: Any]
        guard messageObj["subject"] as! String == TNMessageType.text.rawValue else {
            return 
        }
        guard messageObj["from"] as? String == deviceAddress else {
            return
        }
        var messageModel = TNChatMessageModel()
        messageModel.messageText = messageObj["body"] as! String
        messageModel.messageTime = object["createDate"] as? String
        messageModel.messeageType = .text
        messageModel.senderType = .contact
        if compareDate(newFormatterDate: object["createDate"] as! String) {
            messageModel.isShowTime = true
            messageModel.showTime = TNChatDate.showTimeFormatter(object["createDate"] as! String)
        }
        messages.append(messageModel)
        DispatchQueue.main.async {
            self.updateTableView()
            if self.tableView.y < 0 {
                let moveH = self.getTableMoveHeight()
                UIView.animate(withDuration: 0.2) {
                    self.tableView.y = -moveH
                }
            }
        }
    }
    
    @objc fileprivate func recieveConfirmedNotification(notify: Notification) {
        let object = notify.object as! [String: String]
        let device = object["from"]
        guard device == deviceAddress else {
            return
        }
        DispatchQueue.main.async {
            self.textLabel.text = object["deviceName"]
        }
    }
    
    @objc fileprivate func recieveRemovedMessage(notify: Notification) {
        let device = notify.object as! String
        guard device == deviceAddress else {return}
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

/// MARK: Custom methods
extension TNChatViewController {
    
    fileprivate func updateTableView() {
        tableView.beginUpdates()
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .none)
        tableView.endUpdates()
        autoRollToLastRow(animated: true)
    }
    
    fileprivate func setupUI() {
        view.insertSubview(titleView, belowSubview: navigationBar)
        titleView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(kTitleViewHeight)
        }
        
        titleView.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kLeftMargin)
            make.top.equalToSuperview().offset(kTitleTopMargin)
        }
        
        view.insertSubview(containerView, belowSubview: titleView)
        containerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kSafeAreaBottomH)
            make.top.equalTo(titleView.snp.bottom)
        }
    }
    
    fileprivate func setupContainerView() {
        
        tableView.frame = CGRect(x: 0, y: 0, width: kScreenW, height: containerViewHeight - kTitleViewHeight)
        containerView.addSubview(tableView)
        
        let bottomViewFrame = CGRect(x: 0, y: containerViewHeight - kTitleViewHeight, width: kScreenW, height: kTitleViewHeight)
        bottomInputView = TNChatInputView(frame: bottomViewFrame, containerHeight: containerViewHeight)
        bottomInputView?.delegate = self
        containerView.addSubview(bottomInputView!)
    }
    
    fileprivate func removeCurrentContact() {
        var hint = ""
        if TNLocalizationTool.shared.currentLanguage == "en" {
            hint = "Delete the contact person \"" + correspondentDevice.name + "\" and delete the chat record with the contact"
        } else {
            hint = "将联系人“" + correspondentDevice.name + "”删除，同时删除与该联系人的聊天记录"
        }
        alertAction(self, hint, message: nil, sureActionText: "Confirm".localized, cancelActionText: "Cancel".localized, isChange: true) {[unowned self] in
            let deviceSql = "DELETE FROM correspondent_devices WHERE device_address=?"
            TNSQLiteManager.sharedManager.updateData(sql: deviceSql, values: [self.correspondentDevice.deviceAddress])
            let messageSql = "DELETE FROM chat_messages WHERE correspondent_address=?"
            TNSQLiteManager.sharedManager.updateData(sql: messageSql, values: [self.correspondentDevice.deviceAddress])
            NotificationCenter.default.post(name: Notification.Name(rawValue: TNDidRecievedRemovedNotification), object: self.correspondentDevice.deviceAddress)
            DispatchQueue.global().async {
                TNChatManager.sendRemovedMessage(pubkey: self.correspondentDevice.pubkey, hub: self.correspondentDevice.hub)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    fileprivate func removeCurrentContactChatRecords() {
        var hint = ""
        if TNLocalizationTool.shared.currentLanguage == "en" {
            hint = "Are you sure you want to delete all chat records with " +  correspondentDevice.name + "?"
        } else {
            hint = "确定要删除与" + correspondentDevice.name + "的全部聊天记录？"
        }
        alertAction(self, hint, message: nil, sureActionText: "Confirm".localized, cancelActionText: "Cancel".localized, isChange: true) {[unowned self] in
            let sql = "DELETE FROM chat_messages WHERE correspondent_address=?"
            TNSQLiteManager.sharedManager.updateData(sql: sql, values: [self.correspondentDevice.deviceAddress])
            self.messages.removeAll()
            self.tableView.reloadData()
            NotificationCenter.default.post(name: Notification.Name(rawValue: TNDidRemovedAllChatRecordsNotify), object: self.correspondentDevice.deviceAddress)
        }
    }
    
    fileprivate func getTableMoveHeight() -> CGFloat {
       
        let rect = tableView.rect(forSection: 0)
        
        if rect.size.height >= tableView.height {
            return keyboardH
        }
        if tableView.height > rect.size.height + keyboardH + self.bottomInputView!.textInputRect.height {
            return 0
        }
        let moveHeight = rect.size.height + self.bottomInputView!.textInputRect.height + keyboardH - tableView.height
        return moveHeight
    }
}
