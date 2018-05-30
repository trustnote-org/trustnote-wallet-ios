//
//  TNSyncClonedWalletsView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/29.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNSyncClonedWalletsView: UIView {

    @IBOutlet weak var loadingImageView: UIImageView!
    
    @IBOutlet weak var loadingText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupRadiusCorner(radius: kCornerRadius * 2)
        layer.shadowColor = kGlobalColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 20.0
    }
    
    func startAnimation() {
        let animation:CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        animation.keyTimes = [0,0.5,0.85,1]
        animation.values = [0,CGFloat(Double.pi), CGFloat(Double.pi) * 1.7, CGFloat(Double.pi) * 2]
        animation.isRemovedOnCompletion = false
        animation.repeatCount = MAXFLOAT
        animation.duration = 1.5
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        loadingImageView.layer.add(animation, forKey: "animation")
    }
    
    func stopAnimation() {
        loadingImageView.layer.removeAllAnimations()
    }
}

extension TNSyncClonedWalletsView: TNNibLoadable {
    
    class func syncClonedWalletsView() -> TNSyncClonedWalletsView {
        return TNSyncClonedWalletsView.loadViewFromNib()
    }
}
