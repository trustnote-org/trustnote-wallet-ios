//
//  TNChatInputView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/19.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol TNChatInputVieDelegate: NSObjectProtocol {
    func chatKeyboardWillShow(keyBoardHeight: CGFloat, duration: TimeInterval)
    func chatKeyboardWillHide(duration: TimeInterval)
}

class TNChatInputView: UIView {
    
    let disposeBag = DisposeBag()
    
    let lineView = UIView()
    
    let leftMarigin: CGFloat = 20.0
    
    let topMargin: CGFloat = 8.0
    
    private var inputTextView =  UITextView()
    
    private var textH: CGFloat = 0
    
    private var maxTextH: CGFloat = 0
    
    weak var delegate: TNChatInputVieDelegate?
    
    private var maxNumberOfLines: Int = 4
    
    private var textInputRect = CGRect.zero
    
    private var containerViewHeight: CGFloat = 0
    
    init(frame: CGRect, containerHeight: CGFloat) {
        super.init(frame: frame)
        self.containerViewHeight = containerHeight
        self.textInputRect = frame
        backgroundColor = UIColor.hexColor(rgbValue: 0xF8F9FB)
        setupInputView()
        registerForKeyboardNotifications()
        autoLayoutSubviews()
        maxTextH = ceil(inputTextView.font!.lineHeight * CGFloat(maxNumberOfLines) + inputTextView.textContainerInset.top + inputTextView.textContainerInset.bottom)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TNChatInputView {
    
    fileprivate func autoLayoutSubviews() {
        addSubview(inputTextView)
        inputTextView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(topMargin, leftMarigin, topMargin, leftMarigin))
        }
        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1.0)
        }
    }
    
    fileprivate func setupInputView() {
        lineView.backgroundColor = UIColor.hexColor(rgbValue: 0xE9EFF7)
        inputTextView.font = UIFont.systemFont(ofSize: 16)
        inputTextView.textColor = kThemeTextColor
        inputTextView.scrollsToTop = false
        inputTextView.isScrollEnabled = false
        inputTextView.enablesReturnKeyAutomatically = true
        inputTextView.setupRadiusCorner(radius: 2 * kCornerRadius)
        inputTextView.returnKeyType = .send
    }
    
    fileprivate func registerForKeyboardNotifications() {
    NotificationCenter.default.rx.notification(Notification.Name.UITextViewTextDidChange).subscribe(onNext: {[unowned self] value in
            self.textDidChange()
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
}

extension TNChatInputView {
    
    fileprivate func textDidChange() {
        let height = inputTextView.sizeThatFits(CGSize(width: inputTextView.bounds.size.width, height: CGFloat(MAXFLOAT))).height
        guard height != textH else {
            return
        }
        inputTextView.isScrollEnabled = height > maxTextH
        textH = height
        if !inputTextView.isScrollEnabled {
            textInputRect.size.height = height + 2 * topMargin
            textInputRect.origin.y = containerViewHeight - textInputRect.size.height
            frame = textInputRect
            layoutIfNeeded()
        }
    }
    
    @objc fileprivate func keyboardWillShow(_ notify: Notification) {
        let endFrameValue = notify.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let endFrame = endFrameValue.cgRectValue
        let durationValue = notify.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationValue.floatValue
        delegate?.chatKeyboardWillShow(keyBoardHeight: endFrame.size.height, duration: TimeInterval(duration))
    }
    
    @objc fileprivate func keyboardWillHide(_ notify: Notification) {
        let durationValue = notify.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationValue.floatValue
        delegate?.chatKeyboardWillHide(duration: TimeInterval(duration))
    }
}

