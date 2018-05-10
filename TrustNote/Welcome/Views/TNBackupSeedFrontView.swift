//
//  TNBackupSeedFrontView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/30.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TNBackupSeedFrontView: UIView {
    
    private(set) var disposeBag = DisposeBag()
    
    var clickedNextBlock: (() ->Void)?
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var mnemonicLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    private let warningLabel = UILabel().then {
        
        $0.textColor = UIColor.black
        $0.font = UIFont.boldSystemFont(ofSize: 17.0)
        $0.numberOfLines = 2
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 10.0
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        let warningAttr = NSMutableAttributedString(string: NSLocalizedString("Backup.warning", comment: ""), attributes: [NSAttributedStringKey.paragraphStyle : paragraphStyle])
        $0.attributedText = warningAttr
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        addSubview(warningLabel)
        warningLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(60)
            make.left.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
     
        setupSubViews()
        
        nextButton.rx.tap.asObservable().subscribe(onNext: {[unowned self] in
            
            guard let tapBlock = self.clickedNextBlock else {return}
            
            tapBlock()
            
        }).disposed(by: disposeBag)
    }
}

extension TNBackupSeedFrontView {
    
    fileprivate func setupSubViews() {
        
        descriptionLabel.text = NSLocalizedString("Backup.instruction", comment: "")
        
        nextButton.backgroundColor = UIColor.hexColor(rgbValue: 0x11aaff)
        nextButton.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        nextButton.layer.cornerRadius = 20.0
        nextButton.layer.masksToBounds = true
        
        backgroundView.layer.cornerRadius = 5.0
        backgroundView.layer.masksToBounds = true
    }
}

/// MARK: load nib
extension TNBackupSeedFrontView: TNNibLoadable {
    
    static func backupSeedFrontView() -> TNBackupSeedFrontView {
        
        return TNBackupSeedFrontView.loadViewFromNib()
    }
}
