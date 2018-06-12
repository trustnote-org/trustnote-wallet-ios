//
//  TNWalletSendCell.swift
//  TrustNote
//
//  Created by zengahilong on 2018/6/4.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol TNWalletSendCellProtocol: NSObjectProtocol {
    
    func transfer(amount: String, recieverAddress: String)
    
    func selectTrancsationAddress()
}

class TNWalletSendCell: UITableViewCell, RegisterCellFromNib {
    
    let validAddressCount = 32
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var balanceLabel: TNVerticalAlignLabel!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var selectAddressBtn: UIButton!
    @IBOutlet weak var allSendBtn: UIButton!
    @IBOutlet weak var checkoutBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var addressLine: UIView!
    @IBOutlet weak var amountLine: UIView!
    @IBOutlet weak var addressWarningView: UIView!
    @IBOutlet weak var amountWarningView: UIView!
    @IBOutlet weak var addressWarningLabel: UILabel!
    @IBOutlet weak var amountWarningLabel: UILabel!
    @IBOutlet weak var confirmBtnBottomMarginConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var amountLineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressLineHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: TNWalletSendCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        balanceLabel.verticalAlignment = VerticalAlignmentBottom
        confirmBtn.setupRadiusCorner(radius: kCornerRadius)
        addressTextField.delegate = self
        amountTextField.delegate = self
        addressTextField.addTarget(self, action: #selector(self.textDidChanged(_:)), for: .editingChanged)
        amountTextField.addTarget(self, action: #selector(self.textDidChanged(_:)), for: .editingChanged)
        titleLabel.text = "Send TTT".localized
        descLabel.text = "Remaining balance".localized
        addressTextField.placeholder = "Receiver's wallet address".localized
        amountTextField.placeholder = "Amount".localized
        allSendBtn.setTitle("Send all".localized, for: .normal)
        confirmBtn.setTitle("Confirm".localized, for: .normal)
        instructionLabel.text = "Send.instruction".localized
        checkoutBtn.setTitle("Send.checkout".localized, for: .normal)
        addressWarningLabel.text = "Send.invalidAddress".localized
        amountWarningLabel.text = "Insufficient remaining balance".localized
    }
}

extension TNWalletSendCell {
    
    func scanCallback() {
        if !(addressTextField.text?.isEmpty)! && !(amountTextField.text?.isEmpty)! {
            confirmBtn.isEnabled = true
            confirmBtn.alpha = 1.0
        }
    }
}

extension TNWalletSendCell {
    
    @IBAction func confirm(_ sender: Any) {
        guard addressTextField.text?.length == validAddressCount else {
            addressWarningView.isHidden = false
            return
        }
        TNEvaluateScriptManager.sharedInstance.verifyAddressEffectiveness(address: addressTextField.text!) {[unowned self] (isValid) in
            guard isValid else {
                self.addressWarningView.isHidden = false
                return
            }
            guard (Double(self.amountTextField.text!))! <= (Double(self.balanceLabel.text!))! else {
                self.amountWarningView.isHidden = false
                return
            }
            let amount = Int64(Double(self.amountTextField.text!)! * kBaseOrder)
            self.delegate?.transfer(amount: String(amount), recieverAddress: self.addressTextField.text!)
        }
    }
    
    @IBAction func checkoutDetail(_ sender: Any) {
        
    }
    
    @IBAction func sendAllAmount(_ sender: Any) {
        amountTextField.text = balanceLabel.text
        amountTextField.font = UIFont.systemFont(ofSize: 34)
        if amountTextField.isFirstResponder {
            clearBtn.isHidden = false
        }
        if !(addressTextField.text?.isEmpty)! {
            confirmBtn.isEnabled = true
            confirmBtn.alpha = 1.0
        }
        if !amountWarningView.isHidden {
            amountWarningView.isHidden = true
        }
    }
    
    @IBAction func selectSendAddress(_ sender: Any) {
        delegate?.selectTrancsationAddress()
    }
    
    @IBAction func clear(_ sender: UIButton) {
        amountTextField.text = nil
        amountTextField.font = UIFont.systemFont(ofSize: 16)
        sender.isHidden = true
        confirmBtn.isEnabled = false
        confirmBtn.alpha = 0.3
    }
    
    @objc func textDidChanged(_ textField: UITextField) {
        
        if !(addressTextField.text?.isEmpty)! && !(amountTextField.text?.isEmpty)! {
            confirmBtn.isEnabled = true
            confirmBtn.alpha = 1.0
        } else {
            confirmBtn.isEnabled = false
            confirmBtn.alpha = 0.3
        }
        if textField == amountTextField {
            amountTextField.font = (amountTextField.text?.isEmpty)! ? UIFont.systemFont(ofSize: 16) : UIFont.systemFont(ofSize: 34)
            clearBtn.isHidden = (amountTextField.text?.isEmpty)! ? true : false
        }
    }
}

extension TNWalletSendCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == amountTextField {
            amountLineHeightConstraint.constant = 2
            amountLine.backgroundColor = kGlobalColor
            clearBtn.isHidden = (textField.text?.isEmpty)! ? true : false
            if !amountWarningView.isHidden {
                amountWarningView.isHidden = true
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
        if textField == amountTextField {
            clearBtn.isHidden = true
            amountLineHeightConstraint.constant = 1
            amountLine.backgroundColor = kLineViewColor
        }
        
        if textField == addressTextField {
            addressLineHeightConstraint.constant = 1
            addressLine.backgroundColor = kLineViewColor
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountTextField {
            guard (textField.text?.isEmpty)! else {
                if textField.text!.contains(".") {
                    if string == "." {
                        return false
                    }
                    let deRange = textField.text!.range(of: ".")
                    let backStr = textField.text!.suffix(from: deRange!.upperBound)
                    if backStr.count == 4 && string != "" {
                        return false
                    }
                    return true
                }
                if textField.text == "0" && (string != "." &&  string != "") {
                    return false
                }
                return true
            }
            guard string == "." ||  string == "-" else {
                return true
            }
            return false
        } else {
            if string == "" {
                return true
            }
            if String.isLetterOrNumber(str: string) {
                return true
            }
            return false
        }
    }
}
