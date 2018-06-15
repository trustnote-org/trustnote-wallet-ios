//
//  TNProfileBackupHeadView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/31.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNProfileBackupHeadView: UIView {
    
    fileprivate var isShow = true
    
    var profileBackupHeadViewBlock: ((Bool) -> Void)?
    
    @IBOutlet weak var upImageView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var foldImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descLabel.text = "Hide the mnemonic".localized
        setupShadow(Offset: CGSize(width: 0, height: 10), opacity: 0.2, radius: 5.0)
        upImageView.transform = upImageView.transform.rotated(by: CGFloat(Double.pi))
    }
    
    @IBAction func clickedBtn(_ sender: Any) {
        isShow = !isShow
        descLabel.text = isShow ?  "Hide the mnemonic".localized : "Show the mnemonic".localized
        let imgName = isShow ? "profile_unfold" : "profile_fold"
        foldImageView.image = UIImage(named: imgName)
        upImageView.transform = upImageView.transform.rotated(by: CGFloat(Double.pi))
        profileBackupHeadViewBlock?(isShow)
    }
    
}

extension TNProfileBackupHeadView: TNNibLoadable {
    
    class func profileBackupHeadView() -> TNProfileBackupHeadView {
        
        return TNProfileBackupHeadView.loadViewFromNib()
    }
}

class TNDidDeleteMnemonicView: UIView {
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descLabel.text = "Mnemonic words have been deleted".localized
    }
}

extension TNDidDeleteMnemonicView: TNNibLoadable {
    
    class func didDeleteMnemonicView() -> TNDidDeleteMnemonicView {
        
        return TNDidDeleteMnemonicView.loadViewFromNib()
    }
}
