//
//  TNPopView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/17.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

enum TNPopItem: Int {
    case scan     = 1000
    case contacts = 1001
    case wallet   = 1002
    case code     = 1003
}

protocol TNPopCtrlCellClickDelegate: NSObjectProtocol {
    func popCtrlCellClick(tag: Int)
}

class TNPopView: UIView {

   weak var delegate: TNPopCtrlCellClickDelegate?
   
    init(frame: CGRect, imageNameArr:[String], titleArr:[String]) {
        super.init(frame: UIScreen.main.bounds)
        self.frame = UIScreen.main.bounds
        self.backgroundColor = UIColor.clear
        
        let popCtrl_w = frame.size.width
        let popCtrl_h = frame.size.height
        let popCtrl_x = frame.origin.x
        
        let containerView = UIView(frame: CGRect(x: popCtrl_x, y: frame.origin.y, width: popCtrl_w, height: CGFloat(imageNameArr.count) * popCtrl_h))
        containerView.backgroundColor = UIColor.white
        self.addSubview(containerView)
        containerView.layer.cornerRadius = kCornerRadius
        containerView.layer.shadowColor = kGlobalColor.cgColor
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowRadius = 12.0
        
        for index in 0..<imageNameArr.count {
            let popCtrl_y = CGFloat(index) * popCtrl_h
            var popCtrl_rect = CGRect()
            popCtrl_rect.origin.x = 0
            popCtrl_rect.origin.y = popCtrl_y
            popCtrl_rect.size.width = popCtrl_w
            popCtrl_rect.size.height = popCtrl_h

            var isLastCell: Bool = false

            if index == imageNameArr.count - 1 {
                isLastCell = true
            }

            let popCtrl = TNPopControl(frame: popCtrl_rect, imageName: imageNameArr[index], title: titleArr[index], hiddenLine:isLastCell)
            if index == 0 {
                maskRoundedRect(roundCorners: [.topLeft, .topRight], radio: CGSize(width: kCornerRadius, height: kCornerRadius), rectView: popCtrl)
            }
            if index == imageNameArr.count - 1  {
                maskRoundedRect(roundCorners: [.bottomLeft, .bottomRight], radio: CGSize(width: 8, height: 8), rectView: popCtrl)
            }
            popCtrl.tag = 1000 + index
            popCtrl.addTarget(self, action: #selector(self.popCtrlClick), for: .touchUpInside)
            containerView.addSubview(popCtrl)
        }
        
        let small_w: CGFloat = 12.0
        let small_h: CGFloat = 8.0
        let small_y = frame.origin.y - small_h
        
        var ww: CGFloat
        
        if UIScreen.main.bounds.size.width == 414.0 {//iphone plus
            ww = 15.0
        }else {
            ww = 12.0
        }
        
        let small_x = UIScreen.main.bounds.size.width - 10 - ww - small_w
        var small_rect = CGRect()
        small_rect.origin.x = small_x
        small_rect.origin.y = small_y
        small_rect.size.width = small_w
        small_rect.size.height = small_h
        let smallImageView = UIImageView(frame: small_rect)
        smallImageView.image = UIImage(named: "wallet_popTop")
        self.addSubview(smallImageView)
        
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }) { (view) in
            self.removeFromSuperview()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }) { (view) in
            self.removeFromSuperview()
        }
    }
    
    func maskRoundedRect(roundCorners: UIRectCorner, radio: CGSize, rectView: UIView) {
        let path = UIBezierPath(roundedRect: rectView.bounds, byRoundingCorners: roundCorners, cornerRadii: radio)
        let masklayer: CAShapeLayer = CAShapeLayer()
        masklayer.frame = rectView.bounds
        masklayer.path = path.cgPath
        rectView.layer.mask = masklayer
    }
    
    @objc func popCtrlClick(popCtrl: TNPopControl) {
        guard delegate == nil else {
            delegate?.popCtrlCellClick(tag: popCtrl.tag)
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 0
            }, completion: { (view) in
                self.removeFromSuperview()
            })
            return
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
