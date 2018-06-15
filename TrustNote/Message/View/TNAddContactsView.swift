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
    
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var codeTextView: UITextView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var lineHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleTextLabel.text = "Device Code".localized
        placeHolderLabel.textColor = UIColor.hexColor(rgbValue: 0x999999)
        placeHolderLabel.text = "Scan or enter the device code".localized
        codeTextView.delegate = self
    }
}

extension TNAddContactsView {
    
    @IBAction func scan(_ sender: Any) {
        delegate?.didClickedScanButton()
    }
    
    @IBAction func clear(_ sender: UIButton) {
        codeTextView.text = ""
        sender.isHidden = true
        delegate?.didClickedClearButton()
    }
}

extension TNAddContactsView: TNNibLoadable {
    
    class func addContactsView() -> TNAddContactsView {
        return TNAddContactsView.loadViewFromNib()
    }
}

extension TNAddContactsView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeHolderLabel.isHidden = true
        lineHeightConstraint.constant = 2.0
        lineView.backgroundColor = kGlobalColor
        clearButton.isHidden = codeTextView.text.isEmpty ? true : false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeHolderLabel.isHidden = false
        }
        clearButton.isHidden = true
        lineHeightConstraint.constant = 1.0
        lineView.backgroundColor = kLineViewColor
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty {
            clearButton.isHidden = false
        }
        delegate?.textDidChanged()
    }
    
}
