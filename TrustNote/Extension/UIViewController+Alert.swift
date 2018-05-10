//
//  UIViewController+Alert.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/9.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

protocol ViewControllerAlertProtocol {
    func alertAction(_ target: UIViewController, _ title: String, message: String?, sureActionText: String?, cancelActionText: String, isChange: Bool, sureAction: (() -> Void)?)
}

extension UIViewController: ViewControllerAlertProtocol {
    
    func alertAction(_ target: UIViewController, _ title: String, message: String?, sureActionText: String?, cancelActionText: String, isChange: Bool, sureAction: (() -> Void)?) {
        let alertController = TNAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.isNeedChange = isChange
        let cancelAction = UIAlertAction(title: cancelActionText, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        if let sureActionText = sureActionText {
            let sureAction = UIAlertAction(title: sureActionText, style: .default, handler: {
                action in
                sureAction!()
            })
            alertController.addAction(sureAction)
        }
        self.present(alertController, animated: true, completion: nil)
    }
}

class TNAlertController: UIAlertController {
    
    var isNeedChange: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func addAction(_ action: UIAlertAction) {
        super.addAction(action)
        
        guard isNeedChange else {
            return
        }
        if action.style == .cancel {
            action.setValue(kThemeTextColor, forKey:"titleTextColor")
        }
    }
}
