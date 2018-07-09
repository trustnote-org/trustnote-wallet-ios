//
//  TNPasswordAlertView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/10.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol TNPasswordAlertViewDelegate: NSObjectProtocol  {
    
    func passwordVerifyCorrect(_ password: String)
    
    func didClickedCancelButton()
}

class TNPasswordAlertView: UIView, TNNibLoadable {
    
    typealias ClickedButtonBlock = () -> Void
    
    let disposeBag = DisposeBag()
    
    var verifyCorrectBlock: ClickedButtonBlock?
    var didClickedCancelBlock: ClickedButtonBlock?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorTipLabel: UILabel!
    
    weak var delegate: TNPasswordAlertViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupProperties()
        setupRadiusCorner(radius: kCornerRadius * 2)
        setupShadow(Offset: CGSize(width: 0, height: 2.0), opacity: 0.2, radius: 20)
        cancelButton.rx.tap.asObservable().subscribe(onNext: { [unowned self] _ in
            UIView.animate(withDuration: 0.5,
                           delay:0.01,
                           options:UIViewAnimationOptions.curveEaseInOut,
                           animations:{ ()-> Void in
                            self.removeFromSuperview()
            },
                           completion:{(finished:Bool) -> Void in}
            )
            self.delegate?.didClickedCancelButton()
            self.didClickedCancelBlock?()
            
        }).disposed(by: disposeBag)
        
        confirmButton.rx.tap.asObservable().subscribe(onNext: { [unowned self] _ in
            self.didClickedConfirmButton()
        }).disposed(by: disposeBag)
    }
}

extension TNPasswordAlertView {
    
    fileprivate func setupProperties() {
        titleLabel.text = "Input password".localized
        passwordTextField.placeholder = "Please input password".localized
        errorTipLabel.text = "Verify password error".localized
        confirmButton.setTitle("Confirm".localized, for: .normal)
        cancelButton.setTitle("Cancel".localized, for: .normal)
        confirmButton.setupRadiusCorner(radius: kCornerRadius)
        cancelButton.setupRadiusCorner(radius: kCornerRadius)
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.borderColor = kGlobalColor.cgColor
        passwordTextField.delegate = self
    }
}

/// MARK: EVENT HANDLE
extension TNPasswordAlertView {
    
    fileprivate func shakeAnimation() {
        errorView.shakeAnimation(scope: 5.0)
    }
    
    fileprivate func didClickedConfirmButton() {
        let md5Value = passwordTextField.text?.md5()
        guard md5Value == Preferences[.encryptionPassword] else {
            errorView.isHidden = false
            shakeAnimation()
            return
        }
        TNGlobalHelper.shared.password = passwordTextField.text
        self.delegate?.passwordVerifyCorrect(passwordTextField.text!)
        verifyCorrectBlock?()
        passwordTextField.resignFirstResponder()
    }
    
}

extension TNPasswordAlertView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !errorView.isHidden {
            errorView.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
