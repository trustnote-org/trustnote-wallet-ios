//
//  TNRefreshHeader.swift
//  TrustNote
//
//  Created by zenghailong on 2018/7/10.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNRefreshHeader: GTMRefreshHeader, SubGTMRefreshHeaderProtocol {
   
    
    let loadImgView = UIImageView().then {
        $0.image = UIImage(named: "refresh_loading")
    }
    
    let loadLabel = UILabel().then {
        $0.text = "下拉即可刷新"
        $0.textColor = UIColor.hexColor(rgbValue: 0x8EA0B8)
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(loadImgView)
        self.contentView.addSubview(loadLabel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        loadImgView.frame.size = CGSize(width: 20, height: 20)
        loadImgView.center = CGPoint(x: frame.size.width/2.0 - 20, y: frame.size.height/2.0)
        let labelHeight: CGFloat = 15.0
        let labelWidth: CGFloat = 120
        loadLabel.frame = CGRect(x: loadImgView.frame.maxX + 5, y: (frame.size.height - labelHeight)/2.0, width: labelWidth, height: labelHeight)
    }
    
    
    func startAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2.0
        animation.duration = 1.0
        animation.repeatCount = MAXFLOAT
        animation.isRemovedOnCompletion = false
        loadImgView.layer.add(animation, forKey: "animation")
    }
    
    func stopAnimation() {
        loadImgView.layer.removeAllAnimations()
    }
    
    func toNormalState() {}
    func toRefreshingState() {
        loadLabel.text = "加载中..."
        startAnimation()
    }
    func toPullingState() {
         loadLabel.text = "下拉即可刷新"
    }
    func toWillRefreshState() {}
    func changePullingPercent(percent: CGFloat) {}
    func willCompleteEndRefershing() {
        stopAnimation()
    }
    
    
    func contentHeight() -> CGFloat {
        return 54
    }
    
}
