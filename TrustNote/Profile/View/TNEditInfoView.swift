//
//  TNEditInfoView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/24.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxSwift

class TNEditInfoView: UIView, UITextFieldDelegate {
    
    let disposeBag = DisposeBag()
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var warningView: UIView!
    
    var isEditInfo: Bool? {
        didSet {
            guard isEditInfo! else {
                inputTextField.placeholder = NSLocalizedString(
                    "Please enter the name of the wallet", comment: "")
                warningLabel.text = "不超过10个字符"
                return
            }
            inputTextField.placeholder = NSLocalizedString(
                "Please enter device name", comment: "")
             warningLabel.text = "不超过20个字符"
            let defaultConfig = TNConfigFileManager.sharedInstance.readConfigFile()
            inputTextField.text = defaultConfig["deviceName"] as? String
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        inputTextField.rx.text.orEmpty.asDriver().debounce(0.1)
            .map {$0.count > 0}
            .drive(clearBtn.rx_HiddenState)
            .disposed(by: disposeBag)
        
        clearBtn.rx.tap.asObservable().subscribe (onNext: {[unowned self] _ in
            self.inputTextField.text = nil
            self.clearBtn.isHidden = true
            self.warningView.isHidden = true
        }).disposed(by: disposeBag)
        inputTextField.delegate = self
        inputTextField.becomeFirstResponder()
    }
}

extension TNEditInfoView {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !warningView.isHidden {
            warningView.isHidden = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        return true
    }
}

extension TNEditInfoView: TNNibLoadable {
    
    class func editInfoView() -> TNEditInfoView {
        
        return TNEditInfoView.loadViewFromNib()
    }
}
