//
//  TNObserveWaletAlertView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/19.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxSwift

class TNObserveWaletAlertView: UIView {
    
    let disposeBag = DisposeBag()
    
    var dismissBlock: ClickedDismissButtonBlock?
    
    typealias ClickedNextButtonBlock = () -> Void
    
    var clickedNextButtonBlock: ClickedNextButtonBlock?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dimissBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nextBtn.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        nextBtn.layer.cornerRadius = kCornerRadius
        nextBtn.layer.masksToBounds = true
        
        dimissBtn.rx.tap.asObservable().subscribe(onNext: { [unowned self]  in
            self.dismissBlock?()
        }).disposed(by: disposeBag)
        
        nextBtn.rx.tap.asObservable().subscribe(onNext: { [unowned self]  in
            self.clickedNextButtonBlock?()
        }).disposed(by: disposeBag)
    }
}

extension TNObserveWaletAlertView: TNNibLoadable {
    
    class func observeWaletAlertView() -> TNObserveWaletAlertView {
        
        return TNObserveWaletAlertView.loadViewFromNib()
    }
}
