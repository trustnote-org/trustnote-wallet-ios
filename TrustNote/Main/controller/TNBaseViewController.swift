//
//  TNBaseViewController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/28.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TNBaseNavigationController: UINavigationController  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if !self.viewControllers.isEmpty {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: true)
    }
}

extension TNBaseNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.viewControllers.count == 1 {
            return false
        }
        return true
    }
}

class TNBaseViewController: UIViewController {
   
    let disposeBag = DisposeBag()
    
    var distance: CGFloat = 0.0
    
    var isNeedMove = false {
        didSet {
            if isNeedMove {
                NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillShow)
                .subscribe(onNext: { [unowned self] (notify) in
                    let info = notify.userInfo!
                    let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
                    let keyboardHeight = kScreenH - (keyboardFrame?.size.height)!
                    if self.distance < keyboardHeight {
                        self.view.y -= self.distance
                    } else {
                        self.view.y -= keyboardHeight
                    }
                }).disposed(by: disposeBag)
                
                NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillHide)
                    .subscribe(onNext: { [unowned self] (notify) in
                        self.view.y = 0
                }).disposed(by: disposeBag)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

}

extension TNBaseViewController {
    
    /// setup status bar backgroungColor
    fileprivate func setStatusBarBackgroundColor(color : UIColor) {
        let statusBarWindow: UIView = UIApplication.shared.value(forKey: "statusBarWindow") as! UIView
        let statusBar: UIView = statusBarWindow.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = color
        }
    }
    
}

