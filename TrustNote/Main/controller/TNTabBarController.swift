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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func addChildViewControllers() {
    
        setChildViewController(TNWalletHomeController(), title: "Wallet".localized, imageName: "tabbar_wallet")
        setChildViewController(TNContactViewController(), title: "Message".localized, imageName: "tabbar_message")
        setChildViewController(TNProfileViewController(), title: "Profile".localized, imageName: "tabbar_profile")
    }
    
    private func setChildViewController(_ childController: UIViewController, title: String, imageName: String) {
        
        let navController = TNBaseNavigationController(rootViewController: childController)
        childController.view.backgroundColor = UIColor.white
        navController.setNavigationBarHidden(true, animated: true)
        
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName + "_copy")
        navController.tabBarItem.selectedImage = UIImage(named: imageName)
       navController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.hexColor(rgbValue: 0x4B5461, alpha: 0.6)], for: .normal)
        navController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : kGlobalColor], for: .selected)
        navController.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -1)
        addChildViewController(navController)
    }
}
