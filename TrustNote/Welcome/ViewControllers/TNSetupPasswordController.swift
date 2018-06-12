//
//  TNSetupPasswordController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/7.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

let textValidCount = 8

class TNSetupPasswordController: TNBaseViewController {
    
    
    var isCreateWallet: Bool?
    
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var lastDeleteBtn: UIButton!
    @IBOutlet weak var firstDeleteBtn: UIButton!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var lastWarningLabel: UILabel!
    @IBOutlet weak var firstWarningLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var conflictView: UIView!
    @IBOutlet weak var conflictLabel: UILabel!
    
    @IBOutlet weak var lastLineView: UIView!
    @IBOutlet weak var firstLineView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var warningIconView: UIImageView!
    @IBOutlet weak var warningDescLabel: UILabel!
    @IBOutlet weak var backgroundFrameView: UIView!
    @IBOutlet weak var frameHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var confirmBtnBottomConstraint: NSLayoutConstraint!
    
    let securityLevelView =  TNPasswordSecurityView.passwordSecurityView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextLabel.text = NSLocalizedString("Password.titleText", comment: "")
        warningDescLabel.text = NSLocalizedString("Password.passwordLengthValid", comment: "")
        confirmBtnBottomConstraint.constant = IS_iphone5 ? 30 : 50
        confirmButton.setupRadiusCorner(radius: kCornerRadius)
        confirmButton.setTitle(NSLocalizedString("Confirm", comment: ""), for: .normal)
        backgroundFrameView.setupRadiusCorner(radius: kCornerRadius) 
        backgroundFrameView.layer.masksToBounds = true
        conflictLabel.text = NSLocalizedString("Password.checkInput", comment: "")
        
        firstWarningLabel.attributedText = firstWarningLabel.getAttributeStringWithString(NSLocalizedString("Password.firstWarning", comment: ""), lineSpace: 5.0)
        lastWarningLabel.attributedText = lastWarningLabel.getAttributeStringWithString(NSLocalizedString("Password.secondWarning", comment: ""), lineSpace: 5.0)
        let fontSize = CGSize(width: kScreenW - 83, height: CGFloat(MAXFLOAT))
        let firstSize = firstWarningLabel.textSize(text: NSLocalizedString("Password.firstWarning", comment: ""), font: firstWarningLabel.font, maxSize: fontSize)
        let lastSize = lastWarningLabel.textSize(text: NSLocalizedString("Password.secondWarning", comment: ""), font: firstWarningLabel.font, maxSize: fontSize)
        frameHeightConstraint.constant = firstSize.height + lastSize.height + 40
        
        inputTextField.delegate = self
        
        confirmTextField.delegate = self
        inputTextField.addTarget(self, action: #selector(TNSetupPasswordController.textInputDidChange(_:)), for: .editingChanged)
        confirmTextField.addTarget(self, action: #selector(TNSetupPasswordController.textInputDidChange(_:)), for: .editingChanged)
        
        setupUI()
        
        IQKeyboardManager.shared.enable = false
        distance = IS_iphone5 ? 100 : 0
        isNeedMove = true
    }
}

/// MARK: Handle Event
extension TNSetupPasswordController {
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        guard (inputTextField.text?.count)! > textValidCount - 1 else {
            warningIconView.isHidden = false
            warningDescLabel.isHidden = false
            return
        }
        guard inputTextField.text == confirmTextField.text else {
            conflictView.isHidden = false
            conflictView.shakeAnimation(scope: 5.0)
            return
        }
        let md5Psword = inputTextField.text?.md5()
        Preferences[.encryptionPassword] = md5Psword
        TNGlobalHelper.shared.password = inputTextField.text
        if isCreateWallet! {
            let encPrivKey = AES128CBC_Unit.aes128Encrypt(TNGlobalHelper.shared.tempPrivKey, key: inputTextField.text)
            TNGlobalHelper.shared.encryptePrivKey = encPrivKey!
            TNConfigFileManager.sharedInstance.updateProfile(key: "xPrivKey", value: encPrivKey!)
            TNGlobalHelper.shared.tempPrivKey = ""
        }
        let vc = isCreateWallet! ? TNVBackupsSeedController() : TNRecoveryWalletController()
        Preferences[.isBackupWords] = true
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        if (sender == firstDeleteBtn) {
            inputTextField.text = nil
            firstDeleteBtn.isHidden = true
            if !securityLevelView.isHidden {
                securityLevelView.isHidden = true
            }
            if warningDescLabel.isHidden == false {
                warningDescLabel.isHidden = true
                warningIconView.isHidden = true
            }
        }
        if (sender == lastDeleteBtn) {
            confirmTextField.text = nil
            lastDeleteBtn.isHidden = true
            if !conflictView.isHidden {
                conflictView.isHidden = true
            }
        }
        confirmButton.isEnabled = false
        confirmButton.alpha = 0.3
    }
    
    @objc fileprivate func textInputDidChange(_ textField: UITextField) {
        
        if (inputTextField.text?.count)! > 0 && (confirmTextField.text?.count)! > 0 {
            confirmButton.isEnabled = true
            confirmButton.alpha = 1.0
        } else {
            confirmButton.isEnabled = false
            confirmButton.alpha = 0.3
        }
        if textField == inputTextField {
            firstDeleteBtn.isHidden = textField.text?.count == 0 ? true : false
            if (textField.text?.count)! > textValidCount - 1 {
                securityLevelView.isHidden = false
                if String.isOnlyNumber(str: textField.text!) || String.isAllLetter(str: textField.text!) || String.isAllSpecialCharacter(str: textField.text!) {
                    securityLevelView.level = .weak
                } else if String.containsNumAndLetterAndSpecialCharacter(str: textField.text!) {
                    securityLevelView.level = .strong
                } else {
                    securityLevelView.level = .middle
                }
            } else {
                securityLevelView.isHidden = true
            }
        }
        if textField == confirmTextField {
            lastDeleteBtn.isHidden = textField.text?.count == 0 ? true : false
        }
    }
}

extension TNSetupPasswordController {
    
    fileprivate func setupUI() {
        view.addSubview(securityLevelView)
        securityLevelView.snp.makeConstraints { (make) in
            make.top.equalTo(firstLineView.snp.bottom).offset(8)
            make.left.equalTo(firstLineView.snp.left)
            make.centerX.equalToSuperview()
            make.height.equalTo(75)
        }
    }
}


extension TNSetupPasswordController: UITextFieldDelegate {
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == inputTextField  &&  warningDescLabel.isHidden == false {
            warningDescLabel.isHidden = true
            warningIconView.isHidden = true
        }
        
        if !conflictView.isHidden {
            conflictView.isHidden = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if String.isChineseCharacters(str: string) && string.count != 0 {
            return false
        }
        if string == " " {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

/// MARK: Password Security Varify
extension String {
    
    /// Determine whether the input string is a number
    static func isOnlyNumber(str: String) -> Bool {
        let regex = "^[0-9]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: str)
        return isValid
    }
    
    static func isAllLetter(str: String) -> Bool {
        let regex = "^[A-Za-z]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: str)
        return isValid
    }
    
    static func isAllSpecialCharacter(str: String) -> Bool {
        let regex = "^[^a-zA-Z0-9\u{4E00}-\u{9FA5}]+$" 
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: str)
        return isValid
    }
    
    static func isChineseCharacters(str: String) -> Bool {
        let regex = "^[\u{4E00}-\u{9FA5}]{0,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: str)
        return isValid
    }
    
    static func containsNumAndLetterAndSpecialCharacter(str: String) -> Bool {
        let regex = "^(?![a-zA-Z0-9]+$)(?![^a-zA-Z/D]+$)(?![^0-9/D]+$).{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: str)
        return isValid
    }
    
    static func isLetterOrNumber(str: String) -> Bool {
        let regex = "^[A-Za-z0-9]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: str)
        return isValid
    }
}

