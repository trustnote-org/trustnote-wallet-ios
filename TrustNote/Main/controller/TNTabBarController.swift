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
        let nav = viewControllers![1] as! TNBaseNavigationController
        let vc = nav.viewControllers.first as! TNContactViewController
        var newMessageCount = 0
        for correspondent in vc.dataSource {
            newMessageCount += correspondent.unreadCount
        }
        if newMessageCount == 0 {
            tabBar.hideBadgeOnItemIndex(1)
        } else {
            tabBar.showBadgeOnItemIndex(1)
        }
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

extension UITabBar {
    
    func showBadgeOnItemIndex(_ index : Int) {
        
        removeBadgeOnItemIndex(index)
        
        let badgeView = UIView()
        badgeView.tag = 888 + index
        badgeView.layer.cornerRadius = 3
        badgeView.backgroundColor = UIColor.hexColor(rgbValue: 0xFF4D46)
        let tabFrame = self.frame
        let x = ceilf(Float(tabFrame.size.width / 2 + 5))
        let y = ceilf(0.15 * Float(tabFrame.size.height))
        
        badgeView.frame = CGRect(x: CGFloat(x), y: CGFloat(y), width: 6, height: 6)
        addSubview(badgeView)
    }
    
    func hideBadgeOnItemIndex(_ index : Int){
        removeBadgeOnItemIndex(index)
    }
    
    func removeBadgeOnItemIndex(_ index : Int){
        
        for itemView in self.subviews {
            if(itemView.tag == 888 + index){
                itemView.removeFromSuperview()
            }
        }
    }
}
