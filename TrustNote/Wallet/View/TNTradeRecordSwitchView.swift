//
//  TNTradeRecordSwitchView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/20.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

class TNTradeRecordSwitchView: UIView {

    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var recieveBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sendBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        sendBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0)
        recieveBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        recieveBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0)
    }
   
}

extension TNTradeRecordSwitchView {
    
    @IBAction func transferAccounts(_ sender: Any) {
        
    }
    
    @IBAction func RreceivingTransferring(_ sender: Any) {
        
    }
}

extension TNTradeRecordSwitchView: TNNibLoadable {
    
    class func recordSwitchView() -> TNTradeRecordSwitchView {
        
        return TNTradeRecordSwitchView.loadViewFromNib()
    }

}
