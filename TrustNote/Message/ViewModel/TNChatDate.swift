//
//  TNChatDate.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/26.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import SwiftDate

struct TNChatDate {
    
    static func sortResult(sortedArray: [TNChatMessageModel]) -> Array<TNChatMessageModel> {
        
        let resultArr = sortedArray.sorted {
            return $0.messageTime! < $1.messageTime!
        }
        return resultArr
    }
    
    static func computeVisibleTime(dataArray: [TNChatMessageModel]) -> Array<TNChatMessageModel> {
        var messageArr: [TNChatMessageModel] = []
        var lastVisibleTime = ""
        for i in 0..<dataArray.count {
            var message = dataArray[i]
            if i == 0 {
                message.isShowTime = true
                lastVisibleTime = message.messageTime!
            } else {
                let date1 = getDateFromFormatterTime(lastVisibleTime)
                let date2 = getDateFromFormatterTime(message.messageTime!)
                if isNeedShowTime(date1: date1, date2: date2) {
                    message.isShowTime = true
                    lastVisibleTime = message.messageTime!
                }
            }
            message.showTime = showTimeFormatter(message.messageTime!)
            messageArr.append(message)
        }
        return messageArr
    }
    
    static func isNeedShowTime(date1: Date, date2: Date) -> Bool {
        let timeSpan = compareDate(date1: date1, date2: date2, type: 2)
        if timeSpan >= 5 {
           return true
        }
        return false
    }
    
    static func compareDate(date1: Date, date2: Date, type: Int) -> Int64 {
        let timeInterval = date2.timeIntervalSince(date1)
        var result: Int64 = 0
        switch (type) {
        case 1:
            result = Int64(timeInterval)  //秒
        case 2:
            result = Int64(timeInterval)/60    //分
        case 3:
            result = Int64(timeInterval)/60/60    //时
        case 4:
            result = Int64(timeInterval)/60/60/24    //天
        case 5:
            result = Int64(timeInterval)/60/60/24/30    //月
        case 6:
            result = Int64(timeInterval)/60/60/24/365    //年
        default:
            break;
        }
        return result
    }
    
    static func getDateFromFormatterTime(_ time: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: time)!
    }
    
    static func showTimeFormatter(_ time: String) -> String {
        let timeDate = time.toDate()
        if timeDate!.isToday {
            return timeDate!.toFormat("HH:mm", locale: Locales.chinese)
        }
        if timeDate!.isYesterday {
            return "昨天 " + timeDate!.toFormat("HH:mm")
        }
        return timeDate!.toFormat("yyyy-MM-dd HH:mm")
    }
    
    static func showListTimeFormatter(_ time: String) -> String {
        let timeDate = time.toDate()
        if timeDate!.isToday {
            return timeDate!.toFormat("HH:mm", locale: Locales.chinese)
        }
        if timeDate!.isYesterday {
            return "昨天"
        }
        return timeDate!.toFormat("yyyy-MM-dd")
    }
}
