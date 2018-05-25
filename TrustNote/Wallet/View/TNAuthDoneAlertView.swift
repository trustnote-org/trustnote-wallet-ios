//
//  TNAuthDoneAlertView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/20.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxSwift

class TNAuthDoneAlertView: UIView {
    
    let disposeBag = DisposeBag()
    
    typealias ClickedScanButtonBlock = () -> Void
    
    var clickedScanButtonBlock: ClickedScanButtonBlock?
    
    var clickedDoneButtonBlock: ClickedScanButtonBlock?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var scanningBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var lineTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var invalidImgview: UIImageView!
    @IBOutlet weak var invalidLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 2 * kCornerRadius
        self.layer.masksToBounds = true
        doneBtn.layer.cornerRadius = kCornerRadius
        doneBtn.layer.masksToBounds = true
        
        handleEvent()
    }
}

extension TNAuthDoneAlertView {
    
    fileprivate func handleEvent() {
        
        doneBtn.rx.tap.asObservable().subscribe(onNext: { [unowned self]  in
            self.clickedDoneButtonBlock?()
        }).disposed(by: disposeBag)
        
        scanningBtn.rx.tap.asObservable().subscribe(onNext: { [unowned self]  in
            self.clickedScanButtonBlock?()
        }).disposed(by: disposeBag)
    }
}

extension TNAuthDoneAlertView : TNNibLoadable {
    
    class func authDoneAlertView() -> TNAuthDoneAlertView {
        
        return TNAuthDoneAlertView.loadViewFromNib()
    }
}

