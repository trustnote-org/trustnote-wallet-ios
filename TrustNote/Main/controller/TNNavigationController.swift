//
//  TNNavigationController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/28.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import Then

private let Nav_Bar_Button_Width: CGFloat = 44
private let Nav_Bar_Button_Height: CGFloat = 44

class TNNavigationBar: UIView {
    
    var isNeedMove = false
    
    var leftBarButton: UIButton?
    
    var rightBarButton: UIButton?
    
    var titleText: String? {
        didSet {
            titleLabel.text = titleText ?? ""
        }
    }
    private let contentView = UIView().then {
        $0.backgroundColor = UIColor.clear
    }
    
    private let titleLabel = UILabel().then {
        $0.backgroundColor = UIColor.clear
        $0.textColor = kTitleTextColor
        $0.textAlignment = .center
        $0.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TNNavigationBar {
    
    fileprivate func initUI() {
        
        self.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(kStatusbarH, 0, 0, 0))
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(Nav_Bar_Button_Width)
            make.right.equalToSuperview().offset(-Nav_Bar_Button_Width)
        }
        
    }
    
    public func setLeftButtonTitle(title: String, target: Any?, action: Selector) -> UIButton {
        
        let leftButton = setNavBarButtonTitle(title: title, imageName: "", target: target, action: action)
        layoutNavBarLeftItem(leftButton)
        return leftButton
    }
    
    public func setRightButtonTitle(title: String, target: Any?, action: Selector) -> UIButton {
        let rightButton = setNavBarButtonTitle(title: title, imageName: "", target: target, action: action)
        layoutNavBarRightItem(rightButton)
        return rightButton
    }
    
    public func setLeftButtonImage(imageName: String, target: Any?, action: Selector) -> UIButton {
        let leftButton = setNavBarButtonTitle(title: "", imageName: imageName, target: target, action: action)
        layoutNavBarLeftItem(leftButton)
        return leftButton
    }
    
    public func setRightButtonImage(imageName: String, target: Any?, action: Selector) -> UIButton {
        let rightButton = setNavBarButtonTitle(title: "", imageName: imageName, target: target, action: action)
        layoutNavBarRightItem(rightButton)
        return rightButton
    }
    
    private func setNavBarButtonTitle(title: String, imageName: String, target: Any?, action: Selector) -> UIButton {
        
        let navBarButton = self.navBarButton()
        navBarButton.setTitle(title, for: .normal)
        if imageName.count > 0 {
            navBarButton.setImage(UIImage(named: imageName), for: .normal)
        }
        navBarButton.addTarget(target, action: action, for: .touchUpInside)
        self.contentView.addSubview(navBarButton)
        return navBarButton
    }
    
    private func navBarButton() -> UIButton {
        
        let navBarButton = UIButton(type: .custom)
        navBarButton.setTitleColor(UIColor.hexColor(rgbValue: 0x0076FF), for: .normal)
        navBarButton.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 16)
        return navBarButton
    }
    
    private func layoutNavBarLeftItem(_ navButton: UIButton) {
        
        navButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kLeftMargin)
            make.bottom.equalToSuperview()
            make.width.equalTo(Nav_Bar_Button_Width)
            make.height.equalTo(Nav_Bar_Button_Height)
        }
        leftBarButton = navButton
    }
    
    private func layoutNavBarRightItem(_ navButton: UIButton) {
        
        let offset = isNeedMove ? 5 : 0
        navButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-(15 - offset))
            make.bottom.equalToSuperview()
            make.width.equalTo(Nav_Bar_Button_Width)
            make.height.equalTo(Nav_Bar_Button_Height)
        }
        rightBarButton = navButton
    }
}

class TNNavigationController: TNBaseViewController {
    
    open let navigationBar = TNNavigationBar().then {
        $0.backgroundColor = Navigation_Bar_Color
    }
    
     init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(kNavBarHeight)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension TNNavigationController {
    
    public func setBackButton() {
        _ = navigationBar.setLeftButtonImage(imageName: "welcome_back", target: self, action: #selector(backButtonClicked))
    }
    
   @objc private func backButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
}

