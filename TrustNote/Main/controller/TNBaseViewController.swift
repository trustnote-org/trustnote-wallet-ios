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
    
    var isSetStatusBar: Bool = true {
        didSet {
            guard isSetStatusBar else {
                //setStatusBarBackgroundColor(color: .clear)
                return
            }
            setStatusBarBackgroundColor(color: .black)
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
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

