//
//  TNSQLiteManager.swift
//  TrustNote
//
//  Created by zenghailong on 2018/4/26.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import FMDB

class TNSQLiteManager: NSObject {
    
    static let sharedManager = TNSQLiteManager()
    let dbQueue: FMDatabaseQueue
    let database: FMDatabase
    
    override init() {
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("TrustNote.sqlite")
        dbQueue = FMDatabaseQueue(url: fileURL)
        database = FMDatabase(url: fileURL)
        super.init()
        createTable()
    }
    
    private func createTable() {
        let witnesses = "CREATE TABLE IF NOT EXISTS my_witnesses(" +
            "address VARCHAR(32) NOT NULL PRIMARY KEY" +
        ");"
        let addresses = "CREATE TABLE IF NOT EXISTS my_addresses (" +
            "address CHAR(32) NOT NULL PRIMARY KEY," +
            "wallet CHAR(44) NOT NULL," +
            "is_change TINYINT NOT NULL," +
            "address_index INT NOT NULL," +
            "definition TEXT NOT NULL," +
            "creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP," +
            "UNIQUE (wallet, is_change, address_index)," +
            "FOREIGN KEY (wallet) REFERENCES wallets(wallet)" +
        ");"
        let wallet = "CREATE TABLE IF NOT EXISTS wallets ( " +
            "wallet CHAR(44) NOT NULL PRIMARY KEY," +
            "account INT NOT NULL," +
            "definition_template TEXT NOT NULL," +
            "is_local TINYINT NOT NULL DEFAULT 1," +
            "creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP," +
            "full_approval_date TIMESTAMP NULL," +
            "ready_date TIMESTAMP NULL" +
        ");"
        let extend_pubkeys = "CREATE TABLE IF NOT EXISTS extended_pubkeys( " +
            "wallet CHAR(44) NOT NULL, " +
            "extended_pubkey CHAR(112) NULL," +
            "device_address CHAR(33) NOT NULL," +
            "creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP," +
            "approval_date TIMESTAMP NULL," +
            "member_ready_date TIMESTAMP NULL, " +
            "PRIMARY KEY (wallet, device_address)" +
        ");"
        let wallet_signing_paths = "CREATE TABLE IF NOT EXISTS wallet_signing_paths( " +
            "wallet CHAR(44) NOT NULL," +
            "signing_path VARCHAR(255) NULL," +
            "device_address CHAR(33) NOT NULL," +
            "creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP," +
            "PRIMARY KEY (wallet, signing_path)," +
            "FOREIGN KEY (wallet) REFERENCES wallets(wallet)" +
        ");"
        let input = "CREATE TABLE IF NOT EXISTS inputs( " +
            "unit CHAR(44) NOT NULL," +
            "message_index TINYINT NOT NULL," +
            "input_index TINYINT NOT NULL," +
            "asset CHAR(44) NULL," +
            "denomination INT NOT NULL DEFAULT 1," +
            "is_unique TINYINT NULL DEFAULT 1," +
            "type TEXT CHECK (type IN('transfer','headers_commission','witnessing','issue')) NOT NULL," +
            "src_unit CHAR(44) NULL," +
            "src_message_index TINYINT NULL," +
            "src_output_index TINYINT NULL," +
            "from_main_chain_index INT NULL," +
            "to_main_chain_index INT NULL," +
            "serial_number BIGINT NULL," +
            "amount BIGINT NULL," +
            "address CHAR(32)  NULL," +
            "PRIMARY KEY (unit, message_index, input_index)," +
            "UNIQUE  (src_unit, src_message_index, src_output_index, is_unique)," +
            "UNIQUE  (type, from_main_chain_index, address, is_unique)," +
            "UNIQUE  (asset, denomination, serial_number, address, is_unique)," +
            "FOREIGN KEY (unit) REFERENCES units(unit)" +
        ");"
        let output = "CREATE TABLE IF NOT EXISTS outputs( " +
            "output_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT," +
            "unit CHAR(44) NOT NULL," +
            "message_index TINYINT NOT NULL," +
            "output_index TINYINT NOT NULL," +
            "asset CHAR(44) NULL," +
            "denomination INT NOT NULL DEFAULT 1," +
            "address VARCHAR(32) NULL," +
            "amount BIGINT NOT NULL," +
            "blinding CHAR(16) NULL," +
            "output_hash CHAR(44) NULL," +
            "is_serial TINYINT NULL," +
            "is_spent TINYINT NOT NULL DEFAULT 0," +
            "UNIQUE (unit, message_index, output_index)," +
            "FOREIGN KEY (unit) REFERENCES units(unit)" +
        " );"
        let message = "CREATE TABLE IF NOT EXISTS messages( " +
            "unit CHAR(44) NOT NULL," +
            "message_index TINYINT NOT NULL," +
            "app VARCHAR(30) NOT NULL," +
            "payload_location TEXT CHECK (payload_location IN ('inline','uri','none')) NOT NULL," +
            "payload_hash VARCHAR(44) NOT NULL," +
            "payload TEXT NULL," +
            "payload_uri_hash VARCHAR(44) NULL," +
            "payload_uri VARCHAR(500) NULL," +
            "PRIMARY KEY (unit, message_index)," +
            "FOREIGN KEY (unit) REFERENCES units(unit)" +
        " );"
        let unit = "CREATE TABLE IF NOT EXISTS units( " +
            "unit CHAR(44) NOT NULL PRIMARY KEY," +
            "creation_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP," +
            "version VARCHAR(3) NOT NULL DEFAULT '1.0'," +
            "alt VARCHAR(3) NOT NULL DEFAULT '1'," +
            "witness_list_unit CHAR(44) NULL," +
            "last_ball_unit CHAR(44) NULL," +
            "content_hash CHAR(44) NULL," +
            "headers_commission INT NOT NULL," +
            "payload_commission INT NOT NULL," +
            "is_free TINYINT NOT NULL DEFAULT 1," +
            "is_on_main_chain TINYINT NOT NULL DEFAULT 0," +
            "main_chain_index INT NULL," +
            "latest_included_mc_index INT NULL," +
            "level INT NULL," +
            "witnessed_level INT NULL," +
            "is_stable TINYINT NOT NULL DEFAULT 0," +
            "sequence TEXT CHECK (sequence IN('good','temp-bad','final-bad')) NOT NULL DEFAULT 'good'," +
            "best_parent_unit CHAR(44) NULL," +
            "FOREIGN KEY (best_parent_unit) REFERENCES units(unit)" +
        " );"
        let author = "CREATE TABLE IF NOT EXISTS unit_authors( " +
            "unit CHAR(44) NOT NULL," +
            "address CHAR(32) NOT NULL," +
            "definition_chash CHAR(32) NULL, " +
            "PRIMARY KEY (unit, address)," +
            "FOREIGN KEY (unit) REFERENCES units(unit)," +
            "FOREIGN KEY (definition_chash) REFERENCES definitions(definition_chash)" +
        " );"
        
        dbQueue.inDatabase { (db) -> Void in
            
            if db.executeUpdate(input, withArgumentsIn: []) {
                TNDebugLogManager.debugLog(item: "CREATE INPUTS SUCCESS!")
            }
            db.executeUpdate(witnesses, withArgumentsIn: [])
            db.executeUpdate(addresses, withArgumentsIn: [])
            db.executeUpdate(wallet, withArgumentsIn: [])
            db.executeUpdate(extend_pubkeys, withArgumentsIn: [])
            db.executeUpdate(wallet_signing_paths, withArgumentsIn: [])
            db.executeUpdate(output, withArgumentsIn: [])
            db.executeUpdate(message, withArgumentsIn: [])
            db.executeUpdate(unit, withArgumentsIn: [])
            db.executeUpdate(author, withArgumentsIn: [])
        }
    }
    
}

extension TNSQLiteManager {
    
    public func deleteAllWallets() {
        let tables = ["my_addresses", "wallets", "extended_pubkeys", "inputs", "outputs", "messages", "units", "unit_authors"]
        dbQueue.inDatabase { (database) in
            do {
                for tableName in tables {
                    let sql = String(format:"TRUNCATE FROM %@", arguments:[tableName])
                    try database.executeUpdate(sql, values: nil)
                }
                
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    
    public func updateData(sql: String, values: [Any]) {
        
        dbQueue.inDatabase { (database) in
            do {
                try database.executeUpdate(sql, values: values)
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    
    public func updateDataByExecutingStatements(sql: String) {
        
        dbQueue.inDatabase { (database) in
            let result = database.executeStatements(sql)
            if result {
                TNDebugLogManager.debugLog(item: "UPDATE SUCCESS")
            } else {
                TNDebugLogManager.debugLog(item: "failed")
            }
        }
    }
    
    public func queryDataFromWitnesses(sql: String, completionHandle: (([Any]) -> Swift.Void)?) {
        
        var queryResults: [Any] = []
        dbQueue.inDatabase { (database) in
            do {
                let set = try database.executeQuery(sql, values: nil)
                while set.next() {
                    queryResults.append(set.string(forColumn: "address")!)
                }
                completionHandle!(queryResults)
                set.close()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    
    public func queryDataFromOutputs(sql: String, completionHandle: (([Any]) -> Swift.Void)?) {
        var queryResults: [Any] = []
        dbQueue.inDatabase { (database) in
            do {
                let set = try database.executeQuery(sql, values: nil)
                while set.next() {
                    let unit = set.string(forColumn: "unit")
                    let message_index = set.string(forColumn: "message_index")
                    let output_index = set.string(forColumn: "output_index")
                    let rows: [Any] = [unit!, message_index!, output_index!]
                    queryResults.append(rows)
                }
                completionHandle!(queryResults)
                set.close()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    public func queryAmountFromOutputs(walletId: String, completionHandle: (([Any]) -> Swift.Void)?) {
        var queryResults: [Any] = []
        let sql = "SELECT outputs.address, COALESCE(outputs.asset, 'base') as asset, sum(outputs.amount) as amount\n" +
            "FROM outputs, my_addresses " +
            "WHERE outputs.address = my_addresses.address and outputs.asset IS NULL " +
            "AND my_addresses.wallet = ? " +
            "AND outputs.is_spent=0 " +
            "GROUP BY outputs.address, outputs.asset " +
            "ORDER BY my_addresses.address_index ASC"
        dbQueue.inDatabase { (database) in
            do {
                let set = try database.executeQuery(sql, values: [walletId])
                while set.next() {
                    var balanceModel = TNWalletBalance()
                    balanceModel.address = set.string(forColumn: "address")!
                    balanceModel.amount = set.string(forColumn: "amount")!
                    queryResults.append(balanceModel)
                }
                completionHandle!(queryResults)
                set.close()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    
    public func queryTxUnitsFromUnits(sql: String, value: String, completionHandle: (([TNTxUnits]) -> Swift.Void)?) {
        var queryResults: [TNTxUnits] = []
        dbQueue.inDatabase { (database) in
            do {
                let set = try database.executeQuery(sql, values: [value, value])
                while set.next() {
                    var txUnits = TNTxUnits()
                    txUnits.unit = set.string(forColumn: "unit")!
                    txUnits.level = set.int(forColumn: "level")
                    txUnits.is_stable = set.bool(forColumn: "is_stable")
                    txUnits.sequence = set.string(forColumn: "sequence")!
                    txUnits.address = set.string(forColumn: "address")!
                    let time = set.string(forColumn: "ts")!
                    txUnits.ts = NSDate.getTimeStampFromFormatTime(time: time)
                    txUnits.fee = set.int(forColumn: "fee")
                    txUnits.amount = set.longLongInt(forColumn: "amount")
                    txUnits.to_address = set.string(forColumn: "to_address")!
                    txUnits.from_address = set.string(forColumn: "from_address")!
                    txUnits.mci = set.int(forColumn: "mci")
                    queryResults.append(txUnits)
                }
                completionHandle!(queryResults)
                set.close()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    
    public func queryWalletAddress(sql: String, walletId: String, isChange: Int, completionHandle: (([String]) -> Swift.Void)?) {
        var queryResults: [String] = []
        dbQueue.inDatabase { (database) in
            do {
                let set = try database.executeQuery(sql, values: [walletId, isChange])
                while set.next() {
                    let address = set.string(forColumn: "address")!
                    queryResults.append(address)
                }
                completionHandle!(queryResults)
                set.close()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    
    public func queryFirstWalletAddress(sql: String, walletId: String, completionHandle: (([String]) -> Swift.Void)?) {
        var queryResults: [String] = []
        dbQueue.inDatabase { (database) in
            do {
                let set = try database.executeQuery(sql, values: [walletId])
                while set.next() {
                    let address = set.string(forColumn: "address")!
                    queryResults.append(address)
                }
                completionHandle!(queryResults)
                set.close()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    
    public func queryCount(sql: String, completionHandle: ((Int) -> Swift.Void)?) {
        var count = 0
        dbQueue.inDatabase { (database) in
            do {
                
                let results = try database.executeQuery(sql, values: nil)
                if results.next() {
                    count = Int(results.int(forColumnIndex: 0))
                }
                results.close()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
        completionHandle!(count)
    }
}
