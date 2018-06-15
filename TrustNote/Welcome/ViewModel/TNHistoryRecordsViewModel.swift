//
//  TNHistoryRecordsViewModel.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/25.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation

final class TNHistoryRecordsViewModel: JSONStringFromDictionaryProtocol {
    
    public var historyTransactionModel = TNHistoryTransactionModel()
    
    public var isNeedNotice = false
    
    public var amount = ""
}

extension TNHistoryRecordsViewModel {
    
    func processingTheAcquiredData() {
       
        if let joints = historyTransactionModel.joints.flatMap({ $0 }) {
            guard !joints.isEmpty else {return}
            for unit in joints {
                let objUnit: TNUnitModel = unit.unit!
                saveDataToUnitsTable(unit: objUnit)
            }
            fixIsSpentFlag(joints: joints)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: TNDidFinishUpdateDatabaseNotification), object: nil)
            if isNeedNotice {
                NotificationCenter.default.post(name: Notification.Name(rawValue: TNTransferSendSuccessNotify), object: amount)
            }
        }
        if let proofBalls = historyTransactionModel.proofchain_balls {
            fixIsStableFlag(balls: proofBalls)
        }
    }
    
    func saveDataToUnitsTable(unit: TNUnitModel) {
        let fields = "unit, version, alt, witness_list_unit, last_ball_unit, headers_commission, payload_commission, sequence, main_chain_index, creation_date"
        let values = "?,?,?,?,?,?,?,?,?,?"
        let params = [unit.unit, unit.version, unit.alt, unit.witness_list_unit, unit.last_ball_unit, unit.headers_commission, unit.payload_commission, "good", unit.main_chain_index, NSDate.getFormatterTime(timeStamp: unit.timestamp, formatter: "yyyy年MM月dd日 HH:mm:ss")] as [Any]
        
        let sql = String(format:"INSERT INTO units (%@) VALUES (%@);", arguments:[fields, values])
        let selectSQL = String(format:"SELECT Count(*) FROM units WHERE unit = '%@'", arguments:[unit.unit])
        TNSQLiteManager.sharedManager.queryCount(sql: selectSQL) { (count) in
            guard count == 0 else {
                TNSQLiteManager.sharedManager.updateData(sql: "UPDATE units SET main_chain_index=? WHERE unit=?", values: [unit.main_chain_index, unit.unit])
                return
            }
            TNSQLiteManager.sharedManager.updateData(sql: sql, values: params)
            self.saveDataToMessagesTable(objUnit: unit)
            self.saveDataToAuthorsTable(objUnit: unit)
        }
    }
    
    func saveDataToAuthorsTable(objUnit: TNUnitModel) {
        guard objUnit.authors?.count != 0 else {
            return
        }
        for author in objUnit.authors! {
            let definition = author.definition
            var definition_chash = String()
            if !definition.isEmpty {
                definition_chash = author.address
                TNSQLiteManager.sharedManager.updateData(sql: "INSERT INTO definitions (definition_chash, definition, has_references) VALUES(?,?,0)", values: [definition_chash, TNHistoryRecordsViewModel.getJSONStringFrom(jsonObject: definition)])
            }
            TNSQLiteManager.sharedManager.updateData(sql: "INSERT INTO unit_authors (unit, address, definition_chash) VALUES(?,?,?)", values: [objUnit.unit, author.address, definition_chash])
        }
    }
    
    func saveDataToMessagesTable(objUnit: TNUnitModel) {
        
        if objUnit.content_hash.isEmpty {
            
            for (index, message) in objUnit.messages!.enumerated() {
                var text_payload = String()
                if message.app == "text" {
                    text_payload = (message.payload?.toJSONString())!
                }
                let sql = "INSERT INTO messages (unit, message_index, app, payload_hash, payload_location, payload) VALUES(?,?,?,?,?,?)"
                let params = [objUnit.unit, index, message.app, message.payload_hash, message.payload_location, text_payload] as [Any]
                TNSQLiteManager.sharedManager.updateData(sql: sql, values: params)
                
                if message.app == "payment" {
                    saveDataToOutputsTable(playload: message.payload!, messageIndex: index, objUnit: objUnit)
                    saveDataToInputsTable(playload: message.payload!, messageIndex: index,objUnit: objUnit)
                }
            }
        }
    }
    
    func saveDataToInputsTable(playload: TNPayloadModel, messageIndex: Int, objUnit: TNUnitModel) {
        
        for (index,input) in playload.inputs!.enumerated() {
            let type = input.type.isEmpty ? "transfer" : input.type
            let src_unit = input.unit
            let src_message_index = input.message_index
            let src_output_index = input.output_index
            let address = objUnit.authors?.count == 1 ? objUnit.authors?.first?.address : input.address
            
            if let asset = playload.asset {
                let sql = "INSERT INTO inputs (unit, message_index, input_index, type, src_unit, src_message_index, src_output_index, denomination, amount, serial_number, asset, is_unique, address) VALUES(?,?,?,?,?,?,?,1,?,?,?,1,?)"
                let params = [objUnit.unit, messageIndex, index, type, src_unit, src_message_index, src_output_index, input.amount, input.serial_number, asset, address!] as [Any]
                TNSQLiteManager.sharedManager.updateData(sql: sql, values: params)
            } else {
                let sql = "INSERT INTO inputs (unit, message_index, input_index, type, src_unit, src_message_index, src_output_index, denomination, amount, serial_number, is_unique, address) VALUES(?,?,?,?,?,?,?,1,?,?,1,?)"
                let params = [objUnit.unit, messageIndex, index, type, src_unit, src_message_index, src_output_index, input.amount, input.serial_number, address!] as [Any]
                TNSQLiteManager.sharedManager.updateData(sql: sql, values: params)
            }
        }
    }
    
    func saveDataToOutputsTable(playload: TNPayloadModel, messageIndex: Int, objUnit: TNUnitModel) {
        
        for (outputIndex,output) in playload.outputs!.enumerated() {
            var denomination: Int!
            if output.denomination == nil {
                denomination = 1
            }
            
            if let asset = playload.asset {
                let sql = "INSERT INTO outputs (unit, message_index, output_index, address, amount, denomination, is_serial, asset) VALUES(?,?,?,?,?,?,1,?)"
                let params = [objUnit.unit, messageIndex, outputIndex, output.address, output.amount, denomination, asset] as [Any]
                TNSQLiteManager.sharedManager.updateData(sql: sql, values: params)
            } else {
                let sql = "INSERT INTO outputs (unit, message_index, output_index, address, amount, denomination, is_serial) VALUES(?,?,?,?,?,?,1)"
                let params = [objUnit.unit, messageIndex, outputIndex, output.address, output.amount, denomination] as [Any]
                TNSQLiteManager.sharedManager.updateData(sql: sql, values: params)
            }
            
        }
    }
    
    
    private func fixIsSpentFlag(joints: [TNWetnessJoinsModel]) {
        
        querySpentOutputs()
        for unit in joints {
            let objUnit: TNUnitModel = unit.unit!
            guard isGenesisUnit(objUnit: objUnit) else {
                return
            }
            TNSQLiteManager.sharedManager.updateData(sql: "UPDATE units SET is_on_main_chain=1,main_chain_index=0, is_stable=1, level=0, witnessed_level=0 WHERE unit=?", values: [objUnit])
        }
    }
    
    private func querySpentOutputs() {
        let sql = "SELECT outputs.unit, outputs.message_index, outputs.output_index " +
            "FROM outputs JOIN inputs ON outputs.unit=inputs.src_unit " +
            "AND outputs.message_index=inputs.src_message_index " +
            "AND outputs.output_index=inputs.src_output_index " +
            "WHERE is_spent=0 and outputs.asset IS NULL and inputs.asset IS NULL"
        TNSQLiteManager.sharedManager.queryDataFromOutputs(sql: sql) { (outputs) in
            for row  in outputs as! [[Any]] {
                guard TNSQLiteManager.sharedManager.database.open() else {return}
                do {
                    try TNSQLiteManager.sharedManager.database.executeUpdate("UPDATE outputs SET is_spent=1 WHERE unit=? AND message_index=? AND output_index=?", values: [row[0], row[1], row[2]])
                } catch {
                    print("failed: \(error.localizedDescription)")
                }
                TNSQLiteManager.sharedManager.database.close()
            }
        }
    }
    
    private func isGenesisUnit(objUnit: TNUnitModel) -> Bool {
        
        if objUnit.unit == GENESIS_UNIT {
            return true
        }
        return false
    }
    
    private func fixIsStableFlag(balls: [TNProofchainBallModel]) {
        var goodBallsArr: [String] = []
        var badBallsArr: [String] = []
        for ballModel in balls {
            if ballModel.is_nonserial != nil {
                 badBallsArr.append(ballModel.unit)
            } else {
                goodBallsArr.append(ballModel.unit)
            }
        }
        let goodListArr = goodBallsArr.map {
            return String(format: "'%@'", arguments: [$0])
        }
        let goodList = goodListArr.joined(separator: ",")
        TNSQLiteManager.sharedManager.updateData(sql: "UPDATE units SET is_stable=1 WHERE unit IN(" + goodList + ")", values: nil)
        
        let badListArr = badBallsArr.map {
            return String(format: "'%@'", arguments: [$0])
        }
        let badList = badListArr.joined(separator: ",")
        TNSQLiteManager.sharedManager.updateData(sql: "UPDATE units SET sequence='final-bad' WHERE unit IN(" + badList + ")", values: nil)
    }
    
}
