//
//  TNChatViewController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/15.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNChatViewController: TNNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        _ = navigationBar.setRightButtonImage(imageName: "message_menu", target: self, action: #selector(self.popChatMenu))
    }
}


extension  TNChatViewController: TNPopCtrlCellClickDelegate {
    
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

extension TNChatViewController {
    
    @objc fileprivate func popChatMenu() {
        let popW: CGFloat = TNLocalizationTool.shared.currentLanguage == "en" ? 194 : 154
        let popH: CGFloat = popRowHeight
        let popX = kScreenW - popW - popRightMargin
        let popY: CGFloat = navigationBar.frame.maxY + 8.0
        let imageNameArr = ["message_edit", "message_delete", "message_clear"]
        let titleArr = ["Set Alias".localized, "Delete Contact".localized, "Clear Chat History".localized]
        let popView = TNPopView(frame: CGRect(x: popX, y: popY, width: popW, height: popH), imageNameArr: imageNameArr, titleArr: titleArr)
        popView.delegate = self
    }
}
