//
//  TNCloneWalletController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/29.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNCloneWalletController: TNBaseViewController {
    
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var syncBtnTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewheightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var syncBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    let cloneOperation = TNSyncClonedWallet()
    
    var syncLoadingView : TNCustomAlertView?
    
    fileprivate lazy var loadingView: TNSyncClonedWalletsView = {
        let loadingView = TNSyncClonedWalletsView.loadViewFromNib()
        loadingView.loadingText.text = "SyncLoading".localized
        return loadingView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Sync Cloned Wallets".localized
        descLabel.text = "Press the button to sync".localized
        syncBtn.setTitle("Sync Wallets".localized, for: .normal)
        syncBtn.setupRadiusCorner(radius: kCornerRadius)
        syncBtn.layer.borderColor = kGlobalColor.cgColor
        syncBtn.layer.borderWidth = 1.0
        containerView.setupRadiusCorner(radius: kCornerRadius)
        contentLabel.text = "SyncClonedWallets.warning".localized
        let fontSize = CGSize(width: kScreenW - 87, height: CGFloat(MAXFLOAT))
        let textSize = contentLabel.textSize(text: "SyncClonedWallets.warning".localized, font: contentLabel.font, maxSize: fontSize)
        containerViewheightConstraint.constant = textSize.height + 20
        topMarginConstraint.constant = kStatusbarH
        if IS_iphone5 {
            if TNLocalizationTool.shared.currentLanguage == "en" {
               imageTopMarginConstraint.constant = 10
            }
            syncBtnTopMarginConstraint.constant = 15
            imageWidthConstraint.constant = 170
        }
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNDidFinishRecoverWalletNotification)).subscribe(onNext: {[unowned self] value in
            TNGlobalHelper.shared.recoverStyle = .none
            self.cloneOperation.isRecoverWallet = false
            self.loadingView.stopAnimation()
            self.syncLoadingView?.removeFromSuperview()
            NotificationCenter.default.post(name: Notification.Name(rawValue: TNDidFinishSyncClonedWalletNotify), object: nil)
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
    }
}

extension TNCloneWalletController {
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func syncWallet(_ sender: Any) {
        loadingView.startAnimation()
        let popX = CGFloat(kLeftMargin)
        let popH: CGFloat = 190
        let popY = (kScreenH - popH) / 2
        let popW = kScreenW - popX * 2
        syncLoadingView = TNCustomAlertView(alert: loadingView, alertFrame: CGRect(x: popX, y: popY, width: popW, height: popH), AnimatedType: .none)
        
        cloneOperation.isRecoverWallet = true
        TNGlobalHelper.shared.recoverStyle = .syncCloned
        cloneOperation.syncClonedWallets()
    }
}
