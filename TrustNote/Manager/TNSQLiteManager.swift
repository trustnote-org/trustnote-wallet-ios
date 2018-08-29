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
        
        let definitions = "CREATE TABLE IF NOT EXISTS definitions ( " +
            "definition_chash CHAR(32) NOT NULL PRIMARY KEY," +
            "definition TEXT NOT NULL," +
            "has_references TINYINT NOT NULL " +
        ");"
        
        let correspondent_devices = "CREATE TABLE IF NOT EXISTS correspondent_devices( " +
            "device_address CHAR(33) NOT NULL PRIMARY KEY, " +
            "name VARCHAR(100) NOT NULL, " +
            "pubkey CHAR(44) NOT NULL, " +
            "hub VARCHAR(100) NOT NULL, " +
            "is_confirmed TINYINT NOT NULL DEFAULT 0, " +
            "is_indirect TINYINT NOT NULL DEFAULT 0, " +
            "unread INT NOT NULL DEFAULT 0," +
            "creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP " +
        ");"
        
        let outbox = "CREATE TABLE IF NOT EXISTS outbox( " +
            "message_hash CHAR(44) NOT NULL PRIMARY KEY, " +
            "`to` CHAR(33) NOT NULL, " +
            "message TEXT NOT NULL, " +
            "creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
            "last_error TEXT NULL " +
        ");"
        
        let chat_messages = "CREATE TABLE IF NOT EXISTS chat_messages( " +
            "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, " +
            "correspondent_address CHAR(33) NOT NULL, " +
            "message LONGTEXT NOT NULL, " +
            "creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
            "is_incoming INTEGER(1) NOT NULL, " +
            "type CHAR(15) NOT NULL DEFAULT 'text', " +
            "FOREIGN KEY (correspondent_address) REFERENCES correspondent_devices(device_address) ON DELETE CASCADE " +
        ");"
        
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
            db.executeUpdate(definitions, withArgumentsIn: [])
            db.executeUpdate(correspondent_devices, withArgumentsIn: [])
            db.executeUpdate(outbox, withArgumentsIn: [])
            db.executeUpdate(chat_messages, withArgumentsIn: [])
        }
    }
    
}

extension TNSQLiteManager {
    
    public func deleteAllLocalData() {
        let tables = ["my_addresses", "wallets", "extended_pubkeys", "wallet_signing_paths", "inputs", "outputs", "messages", "units", "unit_authors", "definitions", "correspondent_devices", "outbox", "chat_messages"]
        dbQueue.inDatabase { (database) in
            do {
                for tableName in tables {
                    let sql = String(format:"delete from %@", arguments:[tableName])
                    try database.executeUpdate(sql, values: nil)
                }
                
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    
    public func updateData(sql: String, values: [Any]?) {
        
        guard database.open() else {return}
        do {
            try database.executeUpdate(sql, values: values)
            
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
    }
    
    public func syncUpdateData(sql: String, values: [Any]?) {
        let sema = DispatchSemaphore(value: 0)
        dbQueue.inDatabase { (database) in
            do {
                try database.executeUpdate(sql, values: values)
                sema.signal()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
        _ = sema.wait(timeout:  DispatchTime.distantFuture)
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
    
    public func updateChatMessagesTable(address: String, message: String, date: String, isIncoming: Int, type: String) {
        let sql = "INSERT INTO chat_messages (correspondent_address, message, creation_date, is_incoming, type) VALUES(?,?,?,?,?)"
        //updateData(sql: sql, values: [address, message, date, isIncoming, type])
        syncUpdateData(sql: sql, values: [address, message, date, isIncoming, type])
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
    
    public func queryDataFromOutputs(sql: String) -> [Any] {
        var queryResults: [Any] = []
        let sema = DispatchSemaphore(value: 0)
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
                set.close()
                sema.signal()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
        _ = sema.wait(timeout:  DispatchTime.distantFuture)
        return queryResults
    }
    
    public func queryAmountFromOutputs(walletId: String, isAll: Bool, completionHandle: (([Any]) -> Swift.Void)?) {
        var queryResults: [Any] = []
        let sql = "SELECT outputs.address, COALESCE(outputs.asset, 'base') as asset, sum(outputs.amount) as amount\n" +
            "FROM outputs, my_addresses " +
            "WHERE outputs.address = my_addresses.address and outputs.asset IS NULL " +
            "AND my_addresses.wallet = ? " +
            "AND outputs.is_spent=0 " +
            "GROUP BY outputs.address, outputs.asset " +
        "ORDER BY my_addresses.address_index ASC"
        
        if isAll {
            dbQueue.inDatabase { (database) in
                do {
                    let set = try database.executeQuery(sql, values: [walletId])
                    while set.next() {
                        var balanceModel = TNWalletBalance()
                        balanceModel.address = set.string(forColumn: "address")!
                        balanceModel.amount = set.string(forColumn: "amount")!
                        queryResults.append(balanceModel)
                    }
                    completionHandle?(queryResults)
                    set.close()
                } catch {
                    print("failed: \(error.localizedDescription)")
                }
            }
        } else {
            guard TNSQLiteManager.sharedManager.database.open() else {return}
            do {
                let set = try database.executeQuery(sql, values: [walletId])
                while set.next() {
                    var balanceModel = TNWalletBalance()
                    balanceModel.address = set.string(forColumn: "address")!
                    balanceModel.amount = set.string(forColumn: "amount")!
                    queryResults.append(balanceModel)
                }
                completionHandle?(queryResults)
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
    
    /// TODO UPDATE
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
    
    public func queryWalletAllAddresses(walletId: String, completionHandle: (([TNWalletAddressModel]) -> Swift.Void)?) {
        var queryResults: [TNWalletAddressModel] = []
        let sql = "SELECT * FROM my_addresses WHERE wallet=?"
        dbQueue.inDatabase { (database) in
            do {
                let set = try database.executeQuery(sql, values: [walletId])
                while set.next() {
                    var addressModel = TNWalletAddressModel()
                    addressModel.walletAddress = set.string(forColumn: "address")!
                    addressModel.is_change = set.bool(forColumn: "is_change")
                    queryResults.append(addressModel)
                }
                completionHandle?(queryResults)
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
    
    public func syncQueryCount(sql: String) -> Int {
        var count = 0
        let sema = DispatchSemaphore(value: 0)
        dbQueue.inDatabase { (database) in
            do {
                
                let results = try database.executeQuery(sql, values: nil)
                if results.next() {
                    count = Int(results.int(forColumnIndex: 0))
                }
                results.close()
                sema.signal()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
        _ = sema.wait(timeout: DispatchTime.distantFuture)
        return count
    }
    
    public func queryUnusedChangeAddress(walletId: String, completionHandle: (([String]) -> Swift.Void)?) {
        var queryResults: [String] = []
        let sql = "SELECT my_addresses.* FROM my_addresses " +
            "LEFT JOIN outputs ON outputs.address = my_addresses.address " +
            "WHERE outputs.address IS NULL " +
            "AND my_addresses.wallet = ? " +
            "AND is_change = 1 " +
        "LIMIT 1"
        dbQueue.inDatabase { (database) in
            do {
                let set = try database.executeQuery(sql, values: [walletId])
                while set.next() {
                    let changeAddress = set.string(forColumn: "address")
                    queryResults.append(changeAddress!)
                }
                completionHandle!(queryResults)
                set.close()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    
    public func  queryFundedAddresses(walletId: String, estimateAmount: String, completionHandle: (([TNFundedAddress]) -> Swift.Void)?) {
        var queryResults: [TNFundedAddress] = []
        let sql = "SELECT address, SUM(amount) AS total " +
            "FROM outputs JOIN my_addresses USING(address) " +
            "CROSS JOIN units USING(unit) " +
            "WHERE wallet = ? " +
            "AND is_stable = 1 " +
            "AND sequence = 'good' " +
            "AND is_spent = 0 " +
            "AND asset IS NULL " +
        "GROUP BY address ORDER BY (SUM(amount) > ?) DESC, ABS(SUM(amount) - ?) ASC;"
        dbQueue.inDatabase { (database) in
            do {
                let set = try database.executeQuery(sql, values: [walletId, Int64(estimateAmount)!, Int64(estimateAmount)!])
                while set.next() {
                    var fundedAddress = TNFundedAddress()
                    fundedAddress.address = set.string(forColumn: "address")!
                    fundedAddress.total = set.longLongInt(forColumn: "total")
                    queryResults.append(fundedAddress)
                }
                completionHandle!(queryResults)
                set.close()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    
    public func queryUtxoByAddress(addressList: [String], lastBallMCI: Int, completionHandle: (([TNOutputObject]) -> Swift.Void)?) {
        var queryResults: [TNOutputObject] = []
        let listArr = addressList.map {
            return String(format: "'%@'", arguments: [$0])
        }
        let list = listArr.joined(separator: ",")
        let sql = "SELECT unit, message_index, output_index, amount, address, blinding, is_spent " +
            "FROM outputs " +
            "CROSS JOIN units USING(unit) " +
            "WHERE address IN(" + list + ") " +
            "AND asset IS NULL " +
            "AND is_spent=0 " +
            "AND is_stable=1 " +
            "AND sequence='good' " +
            "AND main_chain_index<= ? " +
        "ORDER BY amount DESC"
        
        dbQueue.inDatabase { (database) in
            do {
                let set = try database.executeQuery(sql, values: [lastBallMCI])
                while set.next() {
                    var output = TNOutputObject()
                    output.unit = set.string(forColumn: "unit")!
                    output.messageIndex = Int(set.int(forColumn: "message_index"))
                    output.outputIndex = Int(set.int(forColumn: "output_index"))
                    output.address = set.string(forColumn: "address")!
                    output.amount = set.longLongInt(forColumn: "amount")
                    queryResults.append(output)
                }
                completionHandle!(queryResults)
                set.close()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    
    public func queryTransferAddress(addressList: [String], completionHandle: (([TNWalletAddressModel]) -> Swift.Void)?) {
        var queryResults: [TNWalletAddressModel] = []
        let listArr = addressList.map {
            return String(format: "'%@'", arguments: [$0])
        }
        let list = listArr.joined(separator: ",")
        let sql = "SELECT * FROM my_addresses WHERE address IN (" + list + ")"
        dbQueue.inDatabase { (database) in
            do {
                let set = try database.executeQuery(sql, values: nil)
                while set.next() {
                    var model = TNWalletAddressModel()
                    model.walletAddress = set.string(forColumn: "address")!
                    model.definition = set.string(forColumn: "definition")!
                    model.is_change = set.bool(forColumn: "is_change")
                    model.walletId = set.string(forColumn: "wallet")!
                    model.address_index = Int(set.int(forColumn: "address_index"))
                    queryResults.append(model)
                }
                completionHandle!(queryResults)
                set.close()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    
    public func queryUnusedAuthorCount(address: String, completionHandle: ((Int) -> Swift.Void)?) {
        var count = 0
        let sql = "SELECT Count(*) FROM definitions WHERE definition_chash = ?"
        dbQueue.inDatabase { (database) in
            do {
                
                let results = try database.executeQuery(sql, values: [address])
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
    
    public func queryContact(deviceAddress: String, completionHandle: (TNCorrespondentDevice) -> Swift.Void) {
        var correspondent = TNCorrespondentDevice()
        let sql = "SELECT * FROM correspondent_devices WHERE device_address = ?"
        dbQueue.inDatabase { (database) in
            do {
                let set = try database.executeQuery(sql, values: [deviceAddress])
                while set.next() {
                    correspondent.deviceAddress = set.string(forColumn: "device_address")!
                    correspondent.hub = set.string(forColumn: "hub")!
                    correspondent.is_confirmed = set.bool(forColumn: "is_confirmed")
                    correspondent.name = set.string(forColumn: "name")!
                    correspondent.pubkey = set.string(forColumn: "pubkey")!
                }
                set.close()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
        completionHandle(correspondent)
    }
    
    public func queryAllCorrespondents(completionHandle: ([TNCorrespondentDevice]) -> Swift.Void) {
        var correspondents: [TNCorrespondentDevice] = []
        dbQueue.inDatabase { (database) in
            do {
                let set = try database.executeQuery("SELECT * FROM correspondent_devices", values: nil)
                while set.next() {
                    var correspondent = TNCorrespondentDevice()
                    correspondent.deviceAddress = set.string(forColumn: "device_address")!
                    correspondent.hub = set.string(forColumn: "hub")!
                    correspondent.is_confirmed = set.bool(forColumn: "is_confirmed")
                    correspondent.name = set.string(forColumn: "name")!
                    correspondent.pubkey = set.string(forColumn: "pubkey")!
                    correspondent.unreadCount = Int(set.int(forColumn: "unread"))
                    correspondents.append(correspondent)
                }
                set.close()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
        completionHandle(correspondents)
    }
    
    public func queryChatMessages(deviceAddress: String, completionHandle: ([TNChatMessageModel]) -> Swift.Void) {
        var messages: [TNChatMessageModel] = []
        let sql = "SELECT * FROM chat_messages WHERE correspondent_address = ?"
        dbQueue.inDatabase { (database) in
            do {
                let set = try database.executeQuery(sql, values: [deviceAddress])
                while set.next() {
                    var messageModel = TNChatMessageModel()
                    messageModel.messageTime = set.string(forColumn: "creation_date")!
                    messageModel.messageText = set.string(forColumn: "message")!
                    let is_incoming = set.bool(forColumn: "is_incoming")
                    messageModel.senderType = is_incoming ? .contact : .oneself
                    let type = set.string(forColumn: "type")!
                    messageModel.messeageType = type == "text" ? .text : .pairing
                    messages.append(messageModel)
                }
                set.close()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
        completionHandle(messages)
    }
    
    public func queryLastMessage(deviceAddress: String, completionHandle: (TNChatMessageModel) -> Swift.Void) {
        var messageModel = TNChatMessageModel()
        dbQueue.inDatabase { (database) in
            do {
                let set = try database.executeQuery("SELECT * FROM chat_messages WHERE correspondent_address = ? ORDER BY id DESC LIMIT 1", values: [deviceAddress])
                while set.next() {
                    messageModel.messageText = set.string(forColumn: "message")!
                    messageModel.messageTime = set.string(forColumn: "creation_date")!
                    let is_incoming = set.bool(forColumn: "is_incoming")
                    messageModel.senderType = is_incoming ? .contact : .oneself
                }
                set.close()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
        completionHandle(messageModel)
    }
    
    public func queryOutbox(completionHandle: ([TNOutbox]) -> Swift.Void) {
        
        var messages: [TNOutbox] = []
        dbQueue.inDatabase { (database) in
            do {
                let set = try database.executeQuery("SELECT * FROM outbox", values: nil)
                while set.next() {
                    var message = TNOutbox()
                    message.message = set.string(forColumn: "message")!
                    message.message_hash = set.string(forColumn: "message_hash")!
                    message.to = set.string(forColumn: "to")!
                    messages.append(message)
                }
                set.close()
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        }
        completionHandle(messages)
    }
    
    public func queryContactHubAddress(deviceAddress: String) -> String {
        var hub = ""
        guard database.open() else {
            return hub
        }
        let sql = "SELECT * FROM correspondent_devices WHERE device_address=?"
        do {
            let set = try database.executeQuery(sql, values: [deviceAddress])
            while set.next() {
                hub = set.string(forColumn: "hub")!
            }
            set.close()
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        return hub
    }
}
