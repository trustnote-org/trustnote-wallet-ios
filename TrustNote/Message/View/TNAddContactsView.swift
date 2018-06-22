//
//  TNAddContactsView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/14.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

protocol TNAddContactsViewDelegate: NSObjectProtocol {
    
    func didClickedScanButton()
    
    func didClickedClearButton()
    
    func textDidChanged()
}

class TNAddContactsView: UIView {

    
    weak var delegate: TNAddContactsViewDelegate?
    
    private var maxNumberOfLines: Int = 3
    
    private var textH: CGFloat = 0
    
    private var maxTextH: CGFloat = 0
    
    @IBOutlet weak var inputTextView: UITextField!
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var lineHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleTextLabel.text = "Device Code".localized
        inputTextView.placeholder = "Scan or enter the device code".localized
        inputTextView.delegate = self
        inputTextView.addTarget(self, action: #selector(TNAddContactsView.textViewDidChange(_:)), for: .editingChanged)
    }
}

extension TNAddContactsView {
    
    @IBAction func scan(_ sender: Any) {
        delegate?.didClickedScanButton()
    }
    
    @IBAction func clear(_ sender: UIButton) {
        inputTextView.text = nil
        sender.isHidden = true
        delegate?.didClickedClearButton()
    }
    
    @objc func textViewDidChange(_ textView: UITextField) {
        clearButton.isHidden = (textView.text?.isEmpty)! ? true : false
        delegate?.textDidChanged()
    }
}

extension TNAddContactsView: TNNibLoadable {
    
    class func addContactsView() -> TNAddContactsView {
        return TNAddContactsView.loadViewFromNib()
    }
}

extension TNAddContactsView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        lineHeightConstraint.constant = 2.0
        lineView.backgroundColor = kGlobalColor
        clearButton.isHidden = (inputTextView.text?.isEmpty)! ? true : false
        if !warningView.isHidden {
            warningView.isHidden = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        clearButton.isHidden = true
        lineHeightConstraint.constant = 1.0
        lineView.backgroundColor = kLineViewColor
    }
    
}
