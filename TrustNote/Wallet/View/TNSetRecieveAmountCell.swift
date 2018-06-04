//
//  TNSetRecieveAmountCell.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/3.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNSetRecieveAmountCell: UITableViewCell, RegisterCellFromNib {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var setRecieveAmountBlock: ((Double) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        titleLabel.text = "Fixed amount".localized
        confirmBtn.setTitle("Confirm".localized, for: .normal)
        setupRadiusCorner(radius: kCornerRadius * 2)
        confirmBtn.setupRadiusCorner(radius: kCornerRadius)
        inputTextField.delegate = self
        inputTextField.addTarget(self, action: #selector(self.textDidChanged(_:)), for: .editingChanged)
    }
}

extension TNSetRecieveAmountCell {
    
    @IBAction func clear(_ sender: Any) {
        inputTextField.text = nil
        confirmBtn.isEnabled = false
        confirmBtn.alpha = 0.3
    }
    
    @IBAction func confirm(_ sender: Any) {
       
        let amount = Double(inputTextField.text!)
        setRecieveAmountBlock?(amount!)
        inputTextField.text = nil
    }
    
    @objc func textDidChanged(_ textField: UITextField) {
        if (textField.text?.length)! > 0 {
            confirmBtn.isEnabled = true
            confirmBtn.alpha = 1.0
        } else {
            confirmBtn.isEnabled = false
            confirmBtn.alpha = 0.3
        }
    }
}

extension TNSetRecieveAmountCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard (textField.text?.isEmpty)! else {
            if textField.text == "0" && string == "0" {
                return false
            }
            return true
        }
        guard string == "." else {
            return true
        }
        return false
    }
}
