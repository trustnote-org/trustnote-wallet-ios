//
//  TNChatViewController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/15.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNChatViewController: TNNavigationController {
    
    let kTitleViewHeight: CGFloat = 50.0
    
    let inputMaxRows = 4
    
    var messages: [TNChatMessageModel] = []
    
    var bottomInputView: TNChatInputView?
    
    var deviceAddress: String!
    
    var correspondentDevice: TNCorrespondentDevice!
    
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
         //autoRollToLastRow()
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
    
    fileprivate func autoRollToLastRow() {
        
        tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .top, animated: false)
    }
    
    fileprivate func getMessageList() {
        
        TNSQLiteManager.sharedManager.queryContact(deviceAddress: deviceAddress) {[unowned self] (correspondent) in
            self.correspondentDevice = correspondent
            self.textLabel.text = correspondent.name
        }
        
        TNSQLiteManager.sharedManager.queryChatMessages(deviceAddress: deviceAddress) {[unowned self] (messageModels) in
            self.messages =  messageModels
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
            break
        case TNPopItem.deleteContact.rawValue - 4 :
            break
        case TNPopItem.clearMessage.rawValue - 4:
            break
        default:
            break
        }
    }
}

extension TNChatViewController: TNChatInputVieDelegate {
    func chatKeyboardWillShow(keyBoardHeight: CGFloat, duration: TimeInterval) {
        UIView.animate(withDuration:duration) {
            self.containerView.frame = CGRect(x: 0, y: self.kTitleViewHeight + kNavBarHeight - keyBoardHeight, width: self.containerView.width, height: self.containerView.height)
            self.titleView.layer.shadowOpacity = 0.1
        }
    }
    
    func chatKeyboardWillHide(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.containerView.frame = CGRect(x: 0, y: self.kTitleViewHeight + kNavBarHeight, width: self.containerView.width, height: self.containerView.height)
            self.titleView.layer.shadowOpacity = 0
        }
    }
    
    func sendMessage(text: String) {
        
        var messageModel = TNChatMessageModel()
        messageModel.messageText = text
        messageModel.messageTime = NSDate.getCurrentFormatterTime()
        messageModel.messeageType = .text
        messageModel.senderType = .oneself
        messages.append(messageModel)
        
        updateTableView()
        
        DispatchQueue.global().async {
            TNChatManager.sendTextMessage(pubkey: self.correspondentDevice.pubkey, hub: self.correspondentDevice.hub, text: text)
        }
        let createDate = NSDate.getCurrentFormatterTime()
        TNSQLiteManager.sharedManager.updateChatMessagesTable(address: deviceAddress, message: text, date: createDate, isIncoming: 0, type: TNMessageType.text.rawValue)
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
        let decryptedObj = object["decryptedObj"] as! [String: Any]
        guard decryptedObj["subject"] as! String == TNMessageType.text.rawValue else {
            return 
        }
        guard decryptedObj["from"] as? String == deviceAddress else {
            return
        }
        var messageModel = TNChatMessageModel()
        messageModel.messageText = decryptedObj["body"] as! String
        messageModel.messageTime = object["createDate"] as? String
        messageModel.messeageType = .text
        messageModel.senderType = .contact
        messages.append(messageModel)
        DispatchQueue.main.async {
            self.updateTableView()
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
    }
    
    fileprivate func setupContainerView() {
        let containerViewHeight = kScreenH - kTitleViewHeight - kSafeAreaBottomH - kNavBarHeight
        tableView.frame = CGRect(x: 0, y: 0, width: kScreenW, height: containerViewHeight - kTitleViewHeight)
        containerView.addSubview(tableView)
        let bottomViewFrame = CGRect(x: 0, y: containerViewHeight - kTitleViewHeight, width: kScreenW, height: kTitleViewHeight)
        bottomInputView = TNChatInputView(frame: bottomViewFrame, containerHeight: containerViewHeight)
        bottomInputView?.delegate = self
        containerView.addSubview(bottomInputView!)
        
        containerView.frame = CGRect(x: 0, y: kTitleViewHeight + kNavBarHeight, width: kScreenW, height: containerViewHeight)
        view.insertSubview(containerView, belowSubview: titleView)
    }
}
