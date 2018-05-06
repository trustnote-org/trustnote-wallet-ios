//
//  TNProtocolViewCell.swift
//  TrustNote
//
//  Created by zenghailong on 2018/3/23.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNProtocolViewCell: UITableViewCell, RegisterCellFromNib {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    var content: String? {
        didSet {
            guard let text = content else {
                return
            }
            contentLabel.text = NSLocalizedString(text, comment: "")
            if text.isEqual("Protocol.sixth")  {
                contentLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
            } else {
                contentLabel.font = UIFont.systemFont(ofSize: 15.0)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        drawRoundView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func drawRoundView() {
        
        let radius: CGFloat = 2.5
       
        let path = UIBezierPath.init(arcCenter: CGPoint(x: containerView.width * 0.5 + 5, y: containerView.height * 0.5), radius: radius, startAngle: 0.0, endAngle: CGFloat(Double.pi * 2), clockwise: true)

        let crcleLayer = CAShapeLayer()
        crcleLayer.path = path.cgPath
        
        let drawColor = UIColor.hexColor(rgbValue: 0x333333)
        crcleLayer.fillColor = drawColor.cgColor
        crcleLayer.strokeColor = drawColor.cgColor
        layer.addSublayer(crcleLayer)
    }
}
