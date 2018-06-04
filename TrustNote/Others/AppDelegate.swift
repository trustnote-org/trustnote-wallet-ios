 //
//  AppDelegate.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/22.
//  Copyright © 2018年 org.trustnote. All rights reserved.


import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setAppLanguage()
        
        /// MARK: Make IQKeyboardManager Effective
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        // Configure global file and save
        TNConfigFileManager.sharedInstance.configGlobalFile()
        // Read profile
        TNGlobalHelper.shared.createGlobalParameters()
        // Load js file
        let file = TNEvaluateScriptManager.loadJsFile(fileName: "core")
        TNEvaluateScriptManager.sharedInstance.evaluatingJavaScriptString(fileString: file)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let config: NSDictionary = TNConfigFileManager.sharedInstance.readConfigFile()
        UIWindow.setWindowRootController(window, rootVC: TNWindowRoot(rawValue: config["keywindowRoot"] as! Int)!)
        window?.makeKeyAndVisible()
        return true
    }
    
    func application(application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: String) -> Bool {
        
        if extensionPointIdentifier == UIApplicationExtensionPointIdentifier.keyboard.rawValue {
            return false
        }
        return true
    }
}

 extension AppDelegate {
    
    func setAppLanguage() {
        var languege: String = ""
        if  (UserDefaults.standard.value(forKey: "langeuage")) != nil {
            languege = UserDefaults.standard.value(forKey: "langeuage") as! String
        }
        TNLocalizationTool.shared.setLanguage(langeuage: languege)
    }
    
    func resetRootViewController() {
        TNGlobalHelper.shared.isNeedLoadData = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        let tabBarController = TNTabBarController()
        window?.rootViewController = tabBarController
        tabBarController.selectedIndex = (tabBarController.viewControllers?.count)! - 1
        let nav = tabBarController.selectedViewController as! TNBaseNavigationController
        let profile = nav.topViewController as! TNProfileViewController
        profile.enterIntoSetting()
    }
    
    func isTabBarRootController() -> Bool {
        let rootVC = (UIApplication.shared.keyWindow?.rootViewController)!
        if rootVC.isKind(of: TNTabBarController.self) {
            return true
        }
        return false
    }
 }
