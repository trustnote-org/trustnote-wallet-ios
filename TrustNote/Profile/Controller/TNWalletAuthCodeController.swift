//
//  TNWalletAuthCodeController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/30.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNWalletAuthCodeController: TNBaseViewController {
    
    @IBOutlet weak var topMarginConstaint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authCodelabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var codeImageView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    
    var wallet: TNWalletModel?
    
    let authSuccessAlert = TNAuthSuccessAlertView.authSuccessAlertView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topMarginConstaint.constant = kStatusbarH
        titleLabel.text = "Cold wallet authentication code".localized
        descLabel.text = "Scan cold wallet code".localized
        nextBtn.setupRadiusCorner(radius: kCornerRadius)
        containerView.layer.borderColor = UIColor.hexColor(rgbValue: 0xF2F2F2).cgColor
        containerView.layer.borderWidth = kCornerRadius
        let qrInput = TNWalletAuthCode().generateWalletAuthCode(wallet: wallet!)
        authCodelabel.text = qrInput
        codeImageView.image = UIImage.createHDQRImage(input: qrInput, imgSize: codeImageView.size)
    }
}

extension TNWalletAuthCodeController {
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let scan = TNScanViewController()
        scan.isPush = false
        scan.scanningCompletionBlock = {[unowned self] result in
            self.scanCompletion(resultStr: result)
        }
        navigationController?.present(scan, animated: true, completion: nil)
    }
    
    fileprivate func scanCompletion(resultStr: String) {
        
        let resultDict = covertJSonStingToDictionary(resultStr)
        let inputMsg = String(format:"TTT:{\"type\":\"%@\",\"addr\":\"%@\",\"v\":%@}", arguments:["c2", TNGlobalHelper.shared.my_device_address, String(resultDict["v"] as! Int)])
        let marginX: CGFloat = 6.0
        let marginY: CGFloat = 58.0
        let alertFrame = CGRect(x: marginX, y: marginY, width: kScreenW - 2 * marginX, height: kScreenH - 2 * marginY)
        authSuccessAlert.codeImageView.image =  UIImage.createHDQRImage(input: inputMsg , imgSize: authSuccessAlert.codeImageView.size)
        
        let authSuccessView = TNCustomAlertView(alert: authSuccessAlert, alertFrame: alertFrame, AnimatedType: .transform)
        authSuccessAlert.dismissBlock = {
            authSuccessView.removeFromSuperview()
        }
        authSuccessAlert.clickedDoneButtonBlock = {[unowned self] in
            authSuccessView.removeFromSuperview()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    fileprivate func covertJSonStingToDictionary(_ inputStr: String) -> [String : Any] {
        let result = inputStr.replacingOccurrences(of:"TTT:", with: "")
        let jsonData:Data = result.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! [String : Any]
        return dict!
    }
}

