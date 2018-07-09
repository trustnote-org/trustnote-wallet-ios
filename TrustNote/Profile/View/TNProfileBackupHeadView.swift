//
//  TNProfileBackupHeadView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/31.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNProfileBackupHeadView: UIView {
    
    var isShow = false
    
    var profileBackupHeadViewBlock: ((Bool, Bool) -> Void)?
    
    var passwordAlertView: TNPasswordAlertView?
    
    @IBOutlet weak var upImageView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var foldImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descLabel.text = "Hide the mnemonic".localized
        setupShadow(Offset: CGSize(width: 0, height: 6), opacity: 0.1, radius: 6.0)
        isShow = Preferences[.isShowMnemonic]
        if isShow {
            upImageView.transform = upImageView.transform.rotated(by: CGFloat(Double.pi))
        }
    }
    
    @IBAction func clickedBtn(_ sender: Any) {
        if isShow {
           handleClickEvent()
        } else {
            verifyWalletPassword()
        }
    }
    
    func handleClickEvent() {
        isShow = !isShow
        Preferences[.isShowMnemonic] = isShow
        upImageView.transform = upImageView.transform.rotated(by: CGFloat(Double.pi))
        showMnemonic(isShow: isShow, animated: true)
    }
    
    func showMnemonic(isShow: Bool, animated: Bool) {
        descLabel.text = isShow ? "Hide the mnemonic".localized : "Show the mnemonic".localized
        let imgName = isShow ? "profile_unfold" : "profile_fold"
        foldImageView.image = UIImage(named: imgName)
        profileBackupHeadViewBlock?(isShow, animated)
    }
    
    fileprivate func verifyWalletPassword() {
        passwordAlertView = TNPasswordAlertView.loadViewFromNib()
        let verifyPasswordView = createPopView(passwordAlertView!, height: 320, animatedType: .none)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture))
        verifyPasswordView.addGestureRecognizer(tap)
        passwordAlertView?.verifyCorrectBlock = {[unowned self] in
            verifyPasswordView.removeFromSuperview()
            self.handleClickEvent()
        }
        passwordAlertView?.didClickedCancelBlock = {
            verifyPasswordView.removeFromSuperview()
        }
    }
    
    @objc fileprivate func handleTapGesture() {
        passwordAlertView!.passwordTextField.resignFirstResponder()
    }
    
    fileprivate func createPopView(_ alert: UIView, height: CGFloat, animatedType: TNAlertAnimatedStyle) -> TNCustomAlertView {
        let popX = CGFloat(kLeftMargin)
        let popH: CGFloat = height
        let popY = (kScreenH - popH) / 2
        let popW = kScreenW - popX * 2
        return TNCustomAlertView(alert: alert, alertFrame: CGRect(x: popX, y: popY, width: popW, height: popH), AnimatedType: animatedType)
    }
    
}

extension TNProfileBackupHeadView: TNNibLoadable {
    
    class func profileBackupHeadView() -> TNProfileBackupHeadView {
        
        return TNProfileBackupHeadView.loadViewFromNib()
    }
}

class TNDidDeleteMnemonicView: UIView {
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descLabel.text = "Mnemonic words have been deleted".localized
    }
}

extension TNDidDeleteMnemonicView: TNNibLoadable {
    
    class func didDeleteMnemonicView() -> TNDidDeleteMnemonicView {
        
        return TNDidDeleteMnemonicView.loadViewFromNib()
    }
}
