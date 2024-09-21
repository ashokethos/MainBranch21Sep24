//
//  GetPurchaseHistory.swift
//  Ethos
//
//  Created by Ashok kumar on 15/07/24.
//

import Foundation


struct GetPurchaseHistory {
    var status: Bool?
    var data: [GetPurchaseHistoryData]?
    
    init(status: Bool, data: [GetPurchaseHistoryData]) {
        self.status = status
        self.data = data
    }
    
    init?(json: [String : Any]) {
        guard let status = json[EthosConstants.status] as? Bool,
              let dataJSON = json[EthosConstants.data] as? [[String: Any]] else {
            return nil
        }
        
        self.status = status
        self.data = dataJSON.compactMap { GetPurchaseHistoryData(json: $0) }
    }
    
    //    init(json : [String : Any]) {
    //        if let status = json[EthosConstants.status] as? Bool {
    //            self.status = status
    //        }
    //
    //        if let data = json[EthosConstants.data] as? [GetPurchaseHistoryData] {
    //            self.data = data
    //        }
    //    }
}

class GetPurchaseHistoryData {
    var invoice_number: String?
    var invoice_type: String?
    var invoice_date: String?
    var brand_name: String?
    var model_number: String?
    var billing_amount: Int?
    var invoiceAttachmentPath: String?
    var watch_category_type: String?
    var price: Int?
    var name: String?
    var case_size: String?
    var gender: String?
    var image: String?
    
    init(invoice_number: String? = nil, invoice_type: String? = nil, invoice_date: String? = nil, brand_name: String? = nil, model_number: String? = nil, billing_amount: Int? = nil, invoiceAttachmentPath: String? = nil, watch_category_type: String? = nil, price: Int? = nil, name: String? = nil, case_size: String? = nil, gender: String? = nil, image: String? = nil) {
        self.invoice_number = invoice_number
        self.invoice_type = invoice_type
        self.invoice_date = invoice_date
        self.brand_name = brand_name
        self.model_number = model_number
        self.billing_amount = billing_amount
        self.invoiceAttachmentPath = invoiceAttachmentPath
        self.watch_category_type = watch_category_type
        self.price = price
        self.name = name
        self.case_size = case_size
        self.gender = gender
        self.image = image
    }
    
    init (json : [String : Any]) {
        if let invoice_number = json["invoice_number"] as? String {
            self.invoice_number = invoice_number
        }
        
        if let invoice_type = json["invoice_type"] as? String {
            self.invoice_type = invoice_type
        }
        
        if let invoice_date = json["invoice_date"] as? String {
            self.invoice_date = invoice_date
        }
        
        if let brand_name = json["brand_name"] as? String {
            self.brand_name = brand_name
        }
        
        if let model_number = json["model_number"] as? String {
            self.model_number = model_number
        }
        
        if let billing_amount = json["billing_amount"] as? Int {
            self.billing_amount = billing_amount
        }
        
        if let invoiceAttachmentPath = json["invoice_attachment_path"] as? String {
            self.invoiceAttachmentPath = invoiceAttachmentPath
        }
        
        if let watch_category_type = json["watch_category_type"] as? String {
            self.watch_category_type = watch_category_type
        }
        
        if let price = json["price"] as? Int {
            self.price = price
        }
        
        if let name = json["name"] as? String {
            self.name = name
        }
        
        if let case_size = json["case_size"] as? String {
            self.case_size = case_size
        }
        
        if let gender = json["gender"] as? String {
            self.gender = gender
        }
        
        if let image = json["image"] as? String {
            self.image = image
        }
    }
}

