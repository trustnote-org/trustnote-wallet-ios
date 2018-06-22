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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        _ = navigationBar.setRightButtonImage(imageName: "message_menu", target: self, action: #selector(self.popChatMenu))
        setupUI()
        setupContainerView()
        addMesages()
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         //autoRollToLastRow()
    }
    
    func addMesages() {
        var messageModel = TNChatMessageModel()
        messageModel.isShowTime = true
        messageModel.messageText = "你已添加了李雷，现在可以开始聊天"
        messageModel.messageTime = "昨天 14:35"
        messageModel.messeageType = .paire
        messageModel.senderType = .oneself
        messages.append(messageModel)
        
        messageModel.isShowTime = true
        messageModel.messageText = "中央军委主席习近平日前签署命令，追授海军某舰载航空兵部队一级飞行员张超“逐梦海天的强军先锋”荣誉称号"
        messageModel.messageTime = "18:35"
        messageModel.messeageType = .text
        messageModel.senderType = .contact
        messages.append(messageModel)
        
        
        messageModel.isShowTime = false
        messageModel.messageText = "张超在驾驶歼-15进行陆基模拟着舰训练时，飞机突发电传故障，不幸壮烈牺牲。中央军委号召，全军和武警部队广大官兵要以张超同志为榜样，高举中国特色社会主义伟大旗帜，坚持以邓小平理论"
        messageModel.messageTime = "18:35"
        messageModel.messeageType = .text
        messageModel.senderType = .oneself
        messages.append(messageModel)
        
        messageModel.isShowTime = true
        messageModel.messageText = "这两个标题不一样么这两个标题不一样么？"
        messageModel.messageTime = "19:30"
        messageModel.messeageType = .text
        messageModel.senderType = .contact
        messages.append(messageModel)
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
}

extension TNChatViewController {
    
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
