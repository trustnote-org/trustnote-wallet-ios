//
//  TNProfileSetupPasswordView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/1.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

protocol TNProfileSetupPasswordViewDelegate: NSObjectProtocol {
    
    func inputDidChanged(_ isValid: Bool)
}

class TNProfileSetupPasswordView: UIView {
    
    weak var delegate: TNProfileSetupPasswordViewDelegate?
    
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var originLine: UIView!
    @IBOutlet weak var newTextField: UITextField!
    @IBOutlet weak var newLine: UIView!
    @IBOutlet weak var passwdRuleLabel: UILabel!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var confirmLine: UIView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var newPasswordView: UIView!
    @IBOutlet weak var newPasswdClearBtn: UIButton!
    @IBOutlet weak var confirmPasswdClearBtn: UIButton!
    
    lazy var passwordSecurityView: TNPasswordSecurityView = {
        let passwordSecurityView = TNPasswordSecurityView.passwordSecurityView()
        passwordSecurityView.isHidden = true
        return passwordSecurityView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        originTextField.placeholder = "Please enter your old password".localized
        newTextField.placeholder = "Please enter your new password".localized
        confirmTextField.placeholder = "Please re-confirm your password".localized
        passwdRuleLabel.text = "Password.passwordLengthValid".localized
        errorLabel.text = "Password.checkInput".localized
        
        newPasswordView.addSubview(passwordSecurityView)
        passwordSecurityView.snp.makeConstraints { (make) in
            make.top.equalTo(newLine.snp.bottom).offset(9)
            make.left.right.equalToSuperview()
            make.height.equalTo(70)
        }
        
        originTextField.addTarget(self, action: #selector(TNProfileSetupPasswordView.textInputDidChange(_:)), for: .editingChanged)
        originTextField.delegate = self
        confirmTextField.addTarget(self, action: #selector(TNProfileSetupPasswordView.textInputDidChange(_:)), for: .editingChanged)
        confirmTextField.delegate = self
        newTextField.addTarget(self, action: #selector(TNProfileSetupPasswordView.textInputDidChange(_:)), for: .editingChanged)
        newTextField.delegate = self
    }
}

extension TNProfileSetupPasswordView: TNNibLoadable {
    
    class func profileSetupPasswordView() -> TNProfileSetupPasswordView {
        
        return TNProfileSetupPasswordView.loadViewFromNib()
    }
}

extension TNProfileSetupPasswordView {
    
    @IBAction func clearNewPasswordText(_ sender: Any) {
        
    }
    
    @IBAction func clearConfirmText(_ sender: Any) {
        
    }
    
    @objc func textInputDidChange(_ textField: UITextField) {
        if !(originTextField.text?.isEmpty)! && !(newTextField.text?.isEmpty)! && !(confirmTextField.text?.isEmpty)! {
            delegate?.inputDidChanged(true)
        } else {
            delegate?.inputDidChanged(false)
        }
        
        if textField == newTextField {
            newPasswdClearBtn.isHidden = (newTextField.text?.length)! > 0 ? false : true
            if (textField.text?.length)! > 0 {
                passwordSecurityView.isHidden = false
                if String.isOnlyNumber(str: textField.text!) || String.isAllLetter(str: textField.text!) || String.isAllSpecialCharacter(str: textField.text!) {
                    passwordSecurityView.level = .weak
                } else if String.containsNumAndLetterAndSpecialCharacter(str: textField.text!) {
                    passwordSecurityView.level = .strong
                } else {
                    passwordSecurityView.level = .middle
                }
            }
        }
        if textField == confirmTextField {
            confirmPasswdClearBtn.isHidden = (confirmTextField.text?.length)! > 0 ? false : true
        }
    }
}

extension TNProfileSetupPasswordView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
}
