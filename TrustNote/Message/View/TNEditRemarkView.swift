//
//  TNEditRemarkView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/25.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxSwift

class TNEditRemarkView: UIView {

    let disposeBag = DisposeBag()
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var warningView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputTextField.placeholder = "设置备注名"
        warningLabel.text = "No more than 10 characters".localized
        inputTextField.rx.text.orEmpty.asDriver().debounce(0.1)
            .map {$0.count > 0}
            .drive(clearButton.rx_HiddenState)
            .disposed(by: disposeBag)
        
        clearButton.rx.tap.asObservable().subscribe (onNext: {[unowned self] _ in
            self.inputTextField.text = nil
            self.clearButton.isHidden = true
            self.warningView.isHidden = true
        }).disposed(by: disposeBag)
        inputTextField.delegate = self
        inputTextField.becomeFirstResponder()
    }
}

extension TNEditRemarkView: TNNibLoadable {
    
    class func editRemarkView() -> TNEditRemarkView {
        
        return TNEditRemarkView.loadViewFromNib()
    }
}

extension TNEditRemarkView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !warningView.isHidden {
            warningView.isHidden = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if string == " " {
//            return false
//        }
        return true
    }
}
