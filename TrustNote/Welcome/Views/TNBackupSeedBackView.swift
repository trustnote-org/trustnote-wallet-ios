//
//  TNBackupSeedBackView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/30.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TNBackupSeedBackView: UIView {
    
    private(set) var disposeBag = DisposeBag()
    
    typealias ClickedButtonBlock = () -> Void
    
    var clickedLastStepBlock: ClickedButtonBlock?
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var seedContainerView: TNSeedContainerView!
    
    @IBOutlet weak var lastStepBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = NSLocalizedString("Confirm your mnemonic words", comment: "")
        tipLabel.text = NSLocalizedString("Backup.tips", comment: "")
        lastStepBtn.setTitle(NSLocalizedString("Last Step", comment: ""), for: .normal)
        
        lastStepBtn.layer.cornerRadius = 20.0
        lastStepBtn.layer.masksToBounds = true
        lastStepBtn.backgroundColor = UIColor.hexColor(rgbValue: 0x11aaff)
        
        lastStepBtn.rx.tap.asObservable().subscribe(onNext: {[unowned self] in
            
            guard let tapBlock = self.clickedLastStepBlock else {return}
            tapBlock()
            
        }).disposed(by: disposeBag)

    }
}

/// MARK: load nib
extension TNBackupSeedBackView: TNNibLoadable {
    
    static func backupSeedBackView() -> TNBackupSeedBackView {
        
        return TNBackupSeedBackView.loadViewFromNib()
    }
}



