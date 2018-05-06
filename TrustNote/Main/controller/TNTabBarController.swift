//
//  TNTabBarController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/3.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabbar = UITabBar.appearance()
        tabbar.isTranslucent = false
        tabbar.barTintColor = kThemeWhiteColor
        addChildViewControllers()
    }
   
    private func addChildViewControllers() {
        setChildViewController(TNWalletViewController(), title: "钱包", imageName: "Home")
        setChildViewController(UIViewController(), title: "消息", imageName: "Home")
        setChildViewController(UIViewController(), title: "我的", imageName: "Home")
    }
    
    private func setChildViewController(_ childController: UIViewController, title: String, imageName: String) {
        
        let navController = UINavigationController(rootViewController: childController)
        childController.view.backgroundColor = UIColor.white
        navController.setNavigationBarHidden(true, animated: true)
        
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        navController.tabBarItem.selectedImage = UIImage(named: imageName)
       navController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black], for: .normal)
        navController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.blue], for: .selected)
        navController.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2)
        addChildViewController(navController)
    }
}
