//
//  GetCustomerModel.swift
//  Ethos
//
//  Created by mac on 26/08/23.
//

import Foundation

class Customer {
    var id, groupID: Int?
    var createdAt, updatedAt, createdIn, email: String?
    var firstname, lastname: String?
    var storeID, websiteID: Int?
    var disableAutoGroupChange: Int?
    var extensionAttributes: ExtentionAttributesForCustomer?
    var customAttributes: [CustomAttribute]?
    var extraAttributes : CustomerExtraAttributes?
    var dateOfBirth : String?
    var gender : String?
    
    init(id: Int?, groupID: Int?, createdAt: String?, updatedAt: String?, createdIn: String?, email: String?, firstname: String?, lastname: String?, storeID: Int?, websiteID: Int?, disableAutoGroupChange: Int?, extensionAttributes: ExtentionAttributesForCustomer?, customAttributes: [CustomAttribute]?) {
        self.id = id
        self.groupID = groupID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.createdIn = createdIn
        self.email = email
        self.firstname = firstname
        self.lastname = lastname
        self.storeID = storeID
        self.websiteID = websiteID
        self.disableAutoGroupChange = disableAutoGroupChange
        self.extensionAttributes = extensionAttributes
        self.customAttributes = customAttributes
    }
    
    
    init(json : [String : Any]) {
        if let id = json[EthosConstants.id] as? Int {
            self.id = id
        }
        
        if let groupID = json[EthosConstants.groupID] as? Int {
            self.groupID = groupID
        }
        
        if let createdAt = json[EthosConstants.createdAt] as? String {
            self.createdAt = createdAt
        }
        
        if let createdIn = json[EthosConstants.createdIn] as? String {
            self.createdIn = createdIn
        }
        
        if let updatedAt = json[EthosConstants.updatedAt] as? String {
            self.updatedAt = updatedAt
        }
        
        if let email = json[EthosConstants.email] as? String {
            self.email = email
        }
        
        if let disableAutoGroupChange = json[EthosConstants.disableAutoGroupChange] as? Int {
            self.disableAutoGroupChange = disableAutoGroupChange
        }
        
        if let firstname = json[EthosConstants.firstname] as? String {
            self.firstname = firstname
        }
        
        if let lastname = json[EthosConstants.lastname] as? String {
            self.lastname = lastname
        }
        
        if let storeID = json[EthosConstants.storeID] as? Int {
            self.storeID = storeID
        }
        
        if let websiteID = json[EthosConstants.webSiteID] as? Int {
            self.websiteID = websiteID
        }
        
        if let gender = json[EthosConstants.gender] as? Int {
            self.gender = gender == 1 ? EthosConstants.male : EthosConstants.female
        }
        
        if let dateOfBirth = json[EthosConstants.dob] as? String {
            self.dateOfBirth = dateOfBirth
        }
        
        if let extensionAttributes = json[EthosConstants.extensionAttributes] as? [String : Any] {
            self.extensionAttributes = ExtentionAttributesForCustomer(json: extensionAttributes)
        }
        
        if let customAttributes = json[EthosConstants.customAttributes] as? [[String : Any]] {
            var arrAttr = [CustomAttribute]()
            
            for attribute in customAttributes {
                let attr = CustomAttribute(json: attribute)
                arrAttr.append(attr)
            }
            
            self.customAttributes = arrAttr
        }
        
        if let extraAttributes = json[EthosConstants.extraAttributes] as? [String : Any] {
            self.extraAttributes = CustomerExtraAttributes(json: extraAttributes)
        }
    }
}
