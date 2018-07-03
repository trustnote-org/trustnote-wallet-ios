//
//  TNTransferViewModel.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/7.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import SwiftyJSON

class TNTransferViewModel: NSObject, TNJSONSerializationProtocol {
    
    var sendFailureBlock: (() -> Void)?
    var sendSuccessBlock: (() -> Void)?
    var totalAsset: Int64 =  0
    let unitMsgTypePayment = "payment"
    let unitPayloadLoationInline = "inline"
    let PLACEHOLDER_AMOUNT: Int64 =  0
    let PLACEHOLDER_HASH = "--------------------------------------------"
    // 88 bytes
    let PLACEHOLDER_SIG = "----------------------------------------------------------------------------------------"
    let MAX_FEE: Int64 = 20000
    
    var unitObject: [String: Any] = [:]
    
    private var sendPaymentInfo =  TNPaymentInfo()
    private var parentUnit: TNParentsUnit?
    private var receiverOutput = TNOutputs()
    private var changeOutput = TNOutputs()
    private var units = TNTransferUnit()
    private var messages = TNMessages()
    private var payload = TNPayload()
    private var authors: [TNAuthors] = []
    private var inputs: [TNInputModel] = []
    
    init(paymentInfo: TNPaymentInfo) {
        super.init()
        self.sendPaymentInfo = paymentInfo
    }
}

extension TNTransferViewModel {
    
    func getReadyToSend() {
        
        DispatchQueue.global().async {
            let response = TNSyncOperationManager.shared.getParentUnit()
            self.parentUnit = TNParentsUnit.deserialize(from: response)
            self.composeUnits()
            self.postNewUnitToHub()
        }
    }
    
    private func composeUnits() {
        
        sendPaymentInfo.lastBallMCI = (parentUnit?.last_stable_mc_ball_mci)!
        
        initUnits()
        
        units.parent_units = parentUnit?.parent_units
        units.last_ball = parentUnit?.last_stable_mc_ball ?? ""
        units.last_ball_unit = parentUnit?.last_stable_mc_ball_unit ?? ""
        units.witness_list_unit = parentUnit?.witness_list_unit ?? ""
        units.headers_commission = PLACEHOLDER_AMOUNT
        units.payload_commission = PLACEHOLDER_AMOUNT
        units.version = TNVersion
        
        let timeInterval: TimeInterval = Date().timeIntervalSince1970
        units.timestamp = Int64(timeInterval)
        
        genPayloadInputs()
        guard !(payload.inputs?.isEmpty)! else {
            DispatchQueue.main.async {
                self.sendFailureBlock?()
            }
            return
        }
        genAuthors()
        
        genCommission()
        
        guard receiverOutput.amount + units.headers_commission + units.payload_commission <= totalAsset else {
            DispatchQueue.main.async {
                self.sendFailureBlock?()
            }
            return
        }
        genChange()
        
        genPayloadHash()
        genUnitsHashAndSign()
    }
    
    private func initUnits() {
        
        receiverOutput.address = sendPaymentInfo.receiverAddress
        receiverOutput.amount = Int64(sendPaymentInfo.amount)!
        
        var changeAddress = queryOrIssueNotUsedChangeAddress()
        if changeAddress.isEmpty {
            changeAddress = TNSyncOperationManager.shared.newChangeAddress(walletId: sendPaymentInfo.walletId, pubkey: sendPaymentInfo.walletPubkey)
        }
        changeOutput.address = changeAddress
        changeOutput.amount = PLACEHOLDER_AMOUNT
        payload.outputs = sortByAddress(outputs: [receiverOutput, changeOutput])
        
        messages.payload_hash = PLACEHOLDER_HASH
        messages.app = unitMsgTypePayment
        messages.payload_location = unitPayloadLoationInline
    }
    
    private func queryOrIssueNotUsedChangeAddress() -> String {
        return TNSyncOperationManager.shared.queryUnusedChangeAddress(walletId: sendPaymentInfo.walletId)
    }
    
    private func genPayloadInputs() {
        
        let fundedAddress = TNSyncOperationManager.shared.queryFundAddressByAmount(walletId: sendPaymentInfo.walletId, estimateAmount: sendPaymentInfo.amount)
        let filterFundedAddres = filterMostFundedAddresses(rows: fundedAddress, estimatedAmount: Int64(sendPaymentInfo.amount)!)
        var addressList: [String] = []
        for fund in filterFundedAddres {
            addressList.append(fund.address)
        }
        
        let outputs = TNSyncOperationManager.shared.queryUtxoByAddress(addressList: addressList, lastBallMCI: sendPaymentInfo.lastBallMCI)
        var res: [TNInputs] = []
        for output in outputs {
            var input = TNInputs()
            var inputModel = TNInputModel()
            input.unit = output.unit
            inputModel.unit = output.unit
            input.message_index = output.messageIndex
            inputModel.message_index = String(output.messageIndex)
            input.output_index = output.outputIndex
            inputModel.output_index = String(output.outputIndex)
            inputModel.amount = String(output.amount)
            inputModel.address = output.address
            res.append(input)
            inputs.append(inputModel)
        }
        payload.inputs = res
        messages.payload = payload
        units.messages = [messages]
    }
    
    private func filterMostFundedAddresses(rows: [TNFundedAddress], estimatedAmount: Int64) -> [TNFundedAddress] {
        var res: [TNFundedAddress] = []
        var accumulatedAmount: Int64 = 0
        for fund in rows {
            res.append(fund)
            accumulatedAmount += fund.total
            if (accumulatedAmount >= estimatedAmount + MAX_FEE) {
                break
            }
        }
        return res
    }
    
    private func genAuthors() {
        var addressList: [String] = []
        if !inputs.isEmpty {
            addressList = inputs.map {
                return $0.address
            }
        }
        let myAddressArr = TNSyncOperationManager.shared.queryTransferAddress(addressList: addressList)
        for addressModel in myAddressArr {
            var author = TNAuthors()
            author.address = addressModel.walletAddress
            author.authentifiers = ["r": PLACEHOLDER_SIG]
            let isAuthorUsed = TNSyncOperationManager.shared.queryUnusedAuthor(address: addressModel.walletAddress)
            if !isAuthorUsed {
                let jsonData: Data = addressModel.definition.data(using: .utf8)!
                let definition = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! [Any]
                author.definition = definition!
            }
            authors.append(author)
        }
        units.authors = authors
    }
    
    private func genChange() {
        
        var totalInput: Int64 = 0
        for input in inputs {
            totalInput += Int64(input.amount)!
        }
        let changeAmount = totalInput - Int64(sendPaymentInfo.amount)! - units.payload_commission - units.headers_commission
        changeOutput.amount = changeAmount
        
        payload.outputs = sortByAddress(outputs: [receiverOutput, changeOutput])
        messages.payload = payload
        units.messages = [messages]
    }
    
    private func genCommission() {
        units.headers_commission = TNSyncOperationManager.shared.getHeadersSizeSync(unit: units.toJSONString()!)
        units.payload_commission = TNSyncOperationManager.shared.getTotalPayloadSync(unit: units.toJSONString()!)
    }
    
    private func genPayloadHash() {
        messages.payload_hash = TNSyncOperationManager.shared.genPayloadHashSync(payload: payload.toJSONString()!)
        units.messages = [messages]
    }
    
    private func genUnitsHashAndSign() {
        var newAuthors: [TNAuthors] = []
        for author in authors {
            let addressmodels = TNSyncOperationManager.shared.queryTransferAddress(addressList: [author.address])
            var bip44Path = ""
            if !addressmodels.isEmpty {
                bip44Path = genBip44Path(addressModel: addressmodels.first!)
            }
            let hashToSign = TNSyncOperationManager.shared.getUnitSignHashSync(unit: filterDefinitionAndRecipients(units: units))
            let sign = TNSyncOperationManager.shared.getTransferSign(b64_hash: hashToSign, xPrivKey: TNGlobalHelper.shared.getPrivkey(), path: bip44Path)
            var newAuthor = author
            newAuthor.authentifiers = ["r": sign]
            newAuthors.append(newAuthor)
        }
        units.authors = newAuthors
        units.unit = TNSyncOperationManager.shared.getUnitHashSync(unit: filterDefinitionAndRecipients(units: units))
        unitObject["unit"] = units.unit
    }
    
    private func sortByAddress(outputs: [TNOutputs]) -> [TNOutputs] {
        return outputs.sorted {
            $0.address < $1.address
        }
    }
    
    private func genBip44Path(addressModel: TNWalletAddressModel) -> String {
        var account = 0
        let credentials = TNConfigFileManager.sharedInstance.readWalletCredentials()
        for dict in credentials {
            let walletModel = TNWalletModel.deserialize(from: dict)
            if walletModel?.walletId == addressModel.walletId {
                account = walletModel!.account
            }
        }
        let isChange = addressModel.is_change ? 1:0
        return String(format:"m/44'/0'/%d'/%d/%d", arguments:[account, isChange, addressModel.address_index])
    }
    
    private func filterDefinitionAndRecipients(units: TNTransferUnit) -> String {
        var unitDict = units.toJSON()
        let authorsDict = unitDict!["authors"] as! [[String: Any]]
        var newAuthorsDict: [[String: Any]] = []
        for authorDict in authorsDict {
            var dict = authorDict
            for (key, value) in dict {
                if key == "definition" {
                    let definition = value as! [Any]
                    if definition.isEmpty {
                        dict.removeValue(forKey: "definition")
                    }
                }
            }
            newAuthorsDict.append(dict)
        }
        unitDict!["authors"] = newAuthorsDict
        if authorsDict.count > 1 {
            unitDict!["earned_headers_commission_recipients"] = [["address" : changeOutput.address, "earned_headers_commission_share": 100]]
        } else {
            unitDict!.removeValue(forKey: "earned_headers_commission_recipients")
        }
        unitObject = unitDict!
        return TNTransferViewModel.getJSONStringFrom(jsonObject: unitDict!)
    }
    
    private func postNewUnitToHub() {
        guard !(payload.inputs?.isEmpty)! else {return}
        let response = TNSyncOperationManager.shared.postTransferUnit(objectJoint: unitObject)
        DispatchQueue.main.async {
            if response == "accepted" {
                let viewModel = TNHistoryRecordsViewModel()
                let unitModel = TNUnitModel.deserialize(from: self.unitObject)
                var joinsModel = TNWetnessJoinsModel()
                joinsModel.unit = unitModel
                viewModel.historyTransactionModel.joints = [joinsModel]
                viewModel.processingTheAcquiredData()
                self.sendSuccessBlock?()
            } else {
                self.sendFailureBlock?()
            }
        }
    }
}
