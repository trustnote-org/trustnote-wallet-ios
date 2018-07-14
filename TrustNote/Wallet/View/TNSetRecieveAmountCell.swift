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
    @IBOutlet weak var deleteBtn: UIButton!
    
    var setRecieveAmountBlock: ((Double) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        titleLabel.text = "Fixed amount".localized
        confirmBtn.setTitle("Confirm".localized, for: .normal)
        //setupShadow(Offset: CGSize(width: 0, height: 2), opacity: 0.2, radius: 10)
        setupRadiusCorner(radius: kCornerRadius * 2)
        layer.masksToBounds = true
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
        deleteBtn.isHidden = true
    }
    
    @IBAction func confirm(_ sender: Any) {
        
        let amount = Double(inputTextField.text!)
        setRecieveAmountBlock?(amount!)
        inputTextField.text = nil
        deleteBtn.isHidden = true
    }
    
    @objc func textDidChanged(_ textField: UITextField) {
        if (textField.text?.length)! > 0 {
            confirmBtn.isEnabled = true
            confirmBtn.alpha = 1.0
            deleteBtn.isHidden = false
        } else {
            confirmBtn.isEnabled = false
            confirmBtn.alpha = 0.3
            deleteBtn.isHidden = true
        }
    }
}

extension TNSetRecieveAmountCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.length == 10 {
            return false
        }
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
        guard string == "." else {
            return true
        }
        return false
    }
}
