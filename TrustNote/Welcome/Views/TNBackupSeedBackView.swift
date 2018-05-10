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
    
    
    @IBOutlet weak var seedContainerView: TNSeedContainerView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}

/// MARK: load nib
extension TNBackupSeedBackView: TNNibLoadable {
    
    static func backupSeedBackView() -> TNBackupSeedBackView {
        return TNBackupSeedBackView.loadViewFromNib()
    }
}



