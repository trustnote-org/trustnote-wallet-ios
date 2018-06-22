//
//  TNMyPairingCodeView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/27.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNMyPairingCodeView: UIView, TNNibLoadable {
   
    var dimissBlock: ClickedDismissButtonBlock?
    
    var pairingCode: String = ""
    
    @IBOutlet weak var copyBtn: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pubkeyLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var codeImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        titlelabel.text = "My pairing code".localized
        descLabel.text = "PairngCode.desc".localized
        copyBtn.setTitle("Copy paire code".localized, for: .normal)
        setupRadiusCorner(radius: kCornerRadius * 2)
        copyBtn.setupRadiusCorner(radius: kCornerRadius)
        containerView.layer.borderColor = UIColor.hexColor(rgbValue: 0xF2F2F2).cgColor
        containerView.layer.borderWidth = kCornerRadius
    }
    
}

extension TNMyPairingCodeView {
    
    @IBAction func dismiss(_ sender: Any) {
        dimissBlock?()
    }
    
    @IBAction func copyCode(_ sender: Any) {
        guard !pairingCode.isEmpty else {
            return
        }
        UIPasteboard.general.string = pairingCode
        let customView = UIImageView(image: UIImage(named: "profile_success"))
        MBProgress_TNExtension.showAlertMessage(alertMessage: "Copy success".localized, customView: customView)
    }
}

extension TNMyPairingCodeView {
    
    public func generateQRcode(completionHandle: @escaping () -> Swift.Void) {
        
        TNChatHelper.getMyDeviceCode { (deviceCode) in
            self.pairingCode = deviceCode
            let inputMsg = TNScanPrefix + deviceCode
            self.codeImageView.image = UIImage.createHDQRImage(input: inputMsg, imgSize: self.codeImageView.size)
            self.pubkeyLabel.text = deviceCode
            completionHandle()
        }
    }
}
