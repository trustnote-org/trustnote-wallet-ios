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
        
        _ = TNSQLiteManager.sharedManager
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
        
        if extensionPointIdentifier.isEqual("com.apple.keyboard-service") {
            return false
        }
        return true
    }
    
}

