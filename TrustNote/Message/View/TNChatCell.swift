//
//  TNChatCell.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/15.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

let BubbleLongPadding: CGFloat = 60
let BubbleShortPadding: CGFloat = CGFloat(kLeftMargin)
let horizontalMargin: CGFloat = 16
let verticalMargin: CGFloat = 12

class TNChatCell: UITableViewCell {
    
    let Padding: CGFloat = CGFloat(kTitleTopMargin + 5)
    
    let textFont = UIFont.systemFont(ofSize: 16.0)
    
    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = UIColor.hexColor(rgbValue: 0xBDCADB)
        $0.textAlignment = .center
    }
    
    let textMeaasgeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.textAlignment = .left
    }
    
    let bubbleImgView = UIImageView().then {
        $0.isUserInteractionEnabled = true
    }
    
    let topLabel = UILabel().then {
        $0.textColor = UIColor.hexColor(rgbValue: 0x8EA0B8)
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.backgroundColor = UIColor.hexColor(rgbValue: 0xE9EFF7)
        $0.layer.cornerRadius = kCornerRadius
        $0.layer.masksToBounds = true
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(topLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(bubbleImgView)
        contentView.addSubview(textMeaasgeLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TNChatCell {
    
    private func configCellWith(messageModel: TNChatMessageModel) {
        
        var topPadding = Padding
        
        if messageModel.isShowTime {
            topPadding += 32
            setupChatTime(messageModel: messageModel)
            timeLabel.isHidden = false
        } else {
            timeLabel.isHidden = true
        }
        if messageModel.messeageType == .pairing {
            setupTopLabel(messageModel: messageModel)
            topLabel.isHidden = false
            bubbleImgView.isHidden = true
            textMeaasgeLabel.isHidden = true
        } else {
            setupChatBubble(messageModel: messageModel, topPadding: topPadding)
            topLabel.isHidden = true
            bubbleImgView.isHidden = false
            textMeaasgeLabel.isHidden = false
        }
    }
    
    private func setupChatTime(messageModel: TNChatMessageModel) {
        timeLabel.text = messageModel.showTime
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Padding)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupTopLabel(messageModel: TNChatMessageModel) {
        topLabel.text = messageModel.messageText
        let maxWidth = kScreenW - CGFloat(2 * kLeftMargin)
        let textSize = UILabel.textSize(text: messageModel.messageText, font: UIFont.systemFont(ofSize: 14), maxSize: CGSize(width: maxWidth, height: CGFloat(MAXFLOAT)))
        topLabel.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom).offset(Padding)
            make.centerX.equalToSuperview()
            make.width.equalTo(textSize.width + horizontalMargin)
            make.height.equalTo(textSize.height + CGFloat(kTitleTopMargin))
        }
    }
    
    private func setupChatBubble(messageModel: TNChatMessageModel, topPadding: CGFloat) {
        let maxWidth = kScreenW - BubbleLongPadding - BubbleShortPadding - 2 * horizontalMargin
        let textSize = UILabel.textSize(text: messageModel.messageText, font: textFont, maxSize: CGSize(width: maxWidth, height: CGFloat(MAXFLOAT)))
        let bubbleW = textSize.width + 2 * horizontalMargin
        let bubbleH = textSize.height + 2 * verticalMargin
        let bubbleX = messageModel.senderType == .contact ? BubbleShortPadding : (kScreenW - bubbleW - BubbleShortPadding)
        bubbleImgView.frame = CGRect(x: bubbleX, y: topPadding, width: bubbleW, height: bubbleH)
        
        let leftCapHeight = 22
        if messageModel.senderType == .contact {
            bubbleImgView.image = UIImage(named: "buddle_other")?.stretchableImage(withLeftCapWidth: leftCapHeight, topCapHeight: leftCapHeight)
            textMeaasgeLabel.textColor = kThemeTextColor
        } else {
            bubbleImgView.image = UIImage(named: "bubble_me")?.stretchableImage(withLeftCapWidth: leftCapHeight, topCapHeight: leftCapHeight)
            textMeaasgeLabel.textColor = UIColor.white
        }
        
        textMeaasgeLabel.text = messageModel.messageText
        textMeaasgeLabel.frame = CGRect(x: bubbleX + horizontalMargin, y: topPadding + verticalMargin, width: textSize.width , height: textSize.height)
    }

}

extension TNChatCell {
    
    static func cellWithTableView(_ tableView: UITableView, messageModel: TNChatMessageModel) -> TNChatCell {
        let identifier = NSStringFromClass(TNChatCell.self)
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? TNChatCell
        if cell == nil {
            cell = TNChatCell(style: .`default`, reuseIdentifier: identifier)
        }
        cell?.configCellWith(messageModel: messageModel)
        return cell!
    }
    
    static func cellHeightWith(messageModel: TNChatMessageModel) -> CGFloat {
        
        var topPadding = kTitleTopMargin
        
        if messageModel.isShowTime {
            topPadding += 32
        }
        let maxWidth = messageModel.messeageType == .pairing ? (kScreenW - CGFloat(2 * kLeftMargin)) : (kScreenW - BubbleLongPadding - BubbleShortPadding - 2 * horizontalMargin)
        let textSize = UILabel.textSize(text: messageModel.messageText, font: UIFont.systemFont(ofSize: 16), maxSize: CGSize(width: maxWidth, height: CGFloat(MAXFLOAT)))
        
        if messageModel.messeageType == .pairing {
            return CGFloat(topPadding) + textSize.height + CGFloat(kTitleTopMargin) + 5
        }
        return CGFloat(topPadding) + textSize.height + CGFloat(kTitleTopMargin + 5) + 2 * verticalMargin
    }
    
}
