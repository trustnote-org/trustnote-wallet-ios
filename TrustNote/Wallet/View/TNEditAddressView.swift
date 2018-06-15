//
//  TNEditAddressView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/12.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

protocol TNEditAddressViewProtocol: NSObjectProtocol {
    
    func didClickedScanButton()
    
    func didClickedSaveButton()
}

class TNEditAddressView: UIView {
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var remarkTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var addressLine: UIView!
    @IBOutlet weak var remarkLine: UIView!
    @IBOutlet weak var addressWarningView: UIView!
    @IBOutlet weak var remarkWarningView: UIView!
    @IBOutlet weak var addressWarningLabel: UILabel!
    @IBOutlet weak var remarkWarningLabel: UILabel!
    
    @IBOutlet weak var remarkLineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressLineHeightConstraint: NSLayoutConstraint!
    
     weak var delegate: TNEditAddressViewProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addressTextField.delegate = self
        remarkTextField.delegate = self
        addressTextField.placeholder = "Wallet address".localized
        remarkTextField.placeholder = "Remarks".localized
        addressWarningLabel.text = "Send.invalidAddress".localized
        remarkWarningLabel.text = "No more than 10 characters".localized
        setupSaveButton(isValid: false)
        saveButton.setTitle("Save".localized, for: .normal)
        saveButton.setupRadiusCorner(radius: kCornerRadius)
        addressTextField.addTarget(self, action: #selector(self.textDidChanged(_:)), for: .editingChanged)
        remarkTextField.addTarget(self, action: #selector(self.textDidChanged(_:)), for: .editingChanged)
    }
    
    public func setupSaveButton(isValid: Bool) {
        if (isValid) {
            saveButton.isEnabled = true
            saveButton.alpha = 1.0
        } else {
            saveButton.isEnabled = false
            saveButton.alpha = 0.3
        }
    }
}

extension TNEditAddressView {
    
    @IBAction func scanning(_ sender: Any) {
        delegate?.didClickedScanButton()
    }
    
    @IBAction func clear(_ sender: UIButton) {
        remarkTextField.text = nil
        sender.isHidden = true
        setupSaveButton(isValid: false)
    }
    
    @IBAction func save(_ sender: Any) {
        guard addressTextField.text?.length == validAddressCount else {
            addressWarningView.isHidden = false
            return
        }
        TNEvaluateScriptManager.sharedInstance.verifyAddressEffectiveness(address: addressTextField.text!) {[unowned self] (isValid) in
            guard isValid else {
                self.addressWarningView.isHidden = false
                return
            }
            guard self.remarkTextField.text!.length <= 10 else {
                self.remarkWarningView.isHidden = false
                return
            }
            self.delegate?.didClickedSaveButton()
        }
    }
    
    @objc func textDidChanged(_ textField: UITextField) {
        
        if !(addressTextField.text?.isEmpty)! && !(remarkTextField.text?.isEmpty)! {
            setupSaveButton(isValid: true)
        } else {
            setupSaveButton(isValid: false)
        }
        if textField == remarkTextField {
            clearButton.isHidden = (textField.text?.isEmpty)! ? true : false
        }
    }
}

extension TNEditAddressView: TNNibLoadable {
    
    class func editAddressView() -> TNEditAddressView {
        
        return TNEditAddressView.loadViewFromNib()
    }
}

extension TNEditAddressView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == remarkTextField {
            remarkLineHeightConstraint.constant = 2
            remarkLine.backgroundColor = kGlobalColor
            clearButton.isHidden = (textField.text?.isEmpty)! ? true : false
            if !remarkWarningView.isHidden {
                remarkWarningView.isHidden = true
            }
        }
        
        if textField == addressTextField {
            addressLineHeightConstraint.constant = 2
            addressLine.backgroundColor = kGlobalColor
            if !addressWarningView.isHidden {
                addressWarningView.isHidden = true
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == remarkTextField {
            clearButton.isHidden = true
            remarkLineHeightConstraint.constant = 1
            remarkLine.backgroundColor = kLineViewColor
        }
        
        if textField == addressTextField {
            addressLineHeightConstraint.constant = 1
            addressLine.backgroundColor = kLineViewColor
        }
    }
}
