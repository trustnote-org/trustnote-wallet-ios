//
//  TNTradeRecordViewModel.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/3.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TNTradeRecordViewModel: NSObject {
    
}

extension TNTradeRecordViewModel {
    
    func queryTransactionRecordList(walletId: String, completionHandle: (([TNTransactionRecord]) -> Swift.Void)?) {
        queryTxUnits(walletId: walletId, completionHandle: completionHandle)
    }
    
    private func queryTxUnits(walletId: String, completionHandle: (([TNTransactionRecord]) -> Swift.Void)?) {
        
        let sql = "SELECT unit, level, is_stable, sequence, address, units.creation_date as ts, headers_commission+payload_commission AS fee, " +
            "SUM(amount) AS amount, address AS to_address, '' AS from_address, main_chain_index AS mci " +
            "FROM units " +
            "JOIN outputs USING(unit) " +
            "JOIN my_addresses USING(address) " +
            "WHERE wallet= ? and asset IS NULL " +
            "GROUP BY unit, address " +
            "UNION " +
            "SELECT unit, level, is_stable, sequence, address, units.creation_date as ts, headers_commission+payload_commission AS fee, " +
            "NULL AS amount, '' AS to_address, address AS from_address, main_chain_index AS mci " +
            "FROM units " +
            "JOIN inputs USING(unit) " +
            "JOIN my_addresses USING(address) " +
            "WHERE wallet= ? and asset IS NULL " +
            "ORDER BY ts DESC"
        TNSQLiteManager.sharedManager.queryTxUnitsFromUnits(sql: sql, value: walletId) { (results) in
            self.handleTxUnits(txUnits: results, walleId: walletId, completionHandle: completionHandle)
        }
    }
    
    private func handleTxUnits(txUnits: [TNTxUnits], walleId: String, completionHandle: (([TNTransactionRecord]) -> Swift.Void)?) {
       
        var assocMovements: [String : TNTxUnits] = [:]
        for txUnit in txUnits {
            var assocUnits = assocMovements.keys.contains(txUnit.unit) ? assocMovements[txUnit.unit] : txUnit
            if let to_address = txUnit.to_address {
                if !to_address.isEmpty {
                    assocUnits?.plus += txUnit.amount
                    assocUnits?.arrMyRecipients.append(["my_address": to_address, "amount": txUnit.amount])
                }
            }
            if let from_address = txUnit.from_address {
                if !from_address.isEmpty {
                    assocUnits?.has_minus = true
                }
            }
            assocMovements[txUnit.unit] = assocUnits
        }
        var arrTransactions: [TNTransactionRecord] = []
        guard !assocMovements.isEmpty else {
            return
        }
        
        for (unit, movement) in assocMovements {
           
            if !movement.sequence.hasPrefix("good") {
               var transaction = TNTransactionRecord()
                transaction.action = .invalid
                transaction.confirmations = movement.is_stable
                transaction.unit = unit
                transaction.fee = movement.fee
                transaction.time = movement.ts
                transaction.level = movement.level
                transaction.mci = movement.mci
                arrTransactions.append(transaction)
            } else if (movement.plus > 0 && !movement.has_minus) {
                let arrPayerAddresses = queryInputAddresses(unit: unit)
                guard !arrPayerAddresses.isEmpty else {return}
                for objRecipient in movement.arrMyRecipients {
                    var transaction = TNTransactionRecord()
                    transaction.action = .received
                    transaction.amount = objRecipient["amount"] as? Int64
                    transaction.my_address = objRecipient["my_address"] as? String
                    transaction.arrPayerAddresses = arrPayerAddresses
                    transaction.confirmations = movement.is_stable
                    transaction.unit = unit
                    transaction.fee = movement.fee
                    transaction.time = movement.ts
                    transaction.level = movement.level
                    transaction.mci = movement.mci
                    arrTransactions.append(transaction)
                }
            } else if (movement.has_minus) {
                let payees = queryOutputAddress(unitId: unit, walletId: walleId)
                let filterPayees = payees.filter {
                    return $0.is_external == true
                }
                let action = filterPayees.isEmpty ? TNTransactionAction.move : TNTransactionAction.sent
                for payee in payees {
                    if (action == .sent && !payee.is_external) {
                        continue
                    }
                    var transaction = TNTransactionRecord()
                    transaction.action = action
                    transaction.amount = payee.amount
                    transaction.addressTo = payee.address
                    transaction.confirmations = movement.is_stable
                    transaction.unit = unit
                    transaction.fee = movement.fee
                    transaction.time = movement.ts
                    transaction.level = movement.level
                    transaction.mci = movement.mci
                    
                    if (action == .move) {
                         transaction.my_address = payee.address
                    }
                    arrTransactions.append(transaction)
                }
            }
        }
        let arrTransactionsSorted = arrTransactions.sorted {
            $0.time > $1.time
        }
        completionHandle!(arrTransactionsSorted)
    }
    
    private func queryInputAddresses(unit: String) -> [String] {
        var queryResults: [String] = []
        guard TNSQLiteManager.sharedManager.database.open() else {return  queryResults}
        let sql = "SELECT DISTINCT address FROM inputs WHERE unit= ? ORDER BY address"
        do {
            let set = try  TNSQLiteManager.sharedManager.database.executeQuery(sql, values: [unit])
            while set.next() {
                queryResults.append(set.string(forColumn: "address")!)
            }
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        TNSQLiteManager.sharedManager.database.close()
        return queryResults
    }
    
    private func queryOutputAddress(unitId: String, walletId: String) -> [TNTxoutputs] {
        var queryResults: [TNTxoutputs] = []
        let sql = "SELECT outputs.address, SUM(amount) AS amount, (my_addresses.address IS NULL) AS is_external " +
            "FROM outputs LEFT JOIN my_addresses ON outputs.address=my_addresses.address AND wallet= ? " +
            "WHERE unit= ? " +
            "GROUP BY outputs.address"
        guard TNSQLiteManager.sharedManager.database.open() else {return  queryResults}
        do {
            let set = try  TNSQLiteManager.sharedManager.database.executeQuery(sql, values: [walletId, unitId])
            while set.next() {
                var txOutputs = TNTxoutputs()
                txOutputs.address = set.string(forColumn: "address")
                txOutputs.amount = set.longLongInt(forColumn: "amount")
                txOutputs.is_external = set.bool(forColumn: "is_external")
                queryResults.append(txOutputs)
            }
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        TNSQLiteManager.sharedManager.database.close()
        return  queryResults
    }
}

