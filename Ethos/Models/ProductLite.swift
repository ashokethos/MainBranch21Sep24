//
//  ProductLite.swift
//  Ethos
//
//  Created by Softgrid on 25/06/24.
//

import UIKit

class ProductLite : NSObject {
    
    var id: Int?
    var sku: String?
    var price: Double?
    var brand: String?
    var collection: String?
    var currency: String?
    var catalogImage: String?

    
    var forPreOwned : Bool = false
    var recentDate : Date?

    
    init(json : [String : Any]) {
        
        if let id = json[EthosConstants.id] as? Int {
            self.id = id
        }
        
        if let sku = json[EthosConstants.sku] as? String {
            self.sku = sku
        }
        
        if let price = json[EthosConstants.price] as? String {
            self.price = Double(price)
        }
        
        if let brand = json[EthosConstants.brand] as? String {
            self.brand = brand
        }
        
        if let collection = json[EthosConstants.collection] as? String {
            self.collection = collection
        }
        
        if let currency = json[EthosConstants.currency] as? String {
            self.currency = currency
        }
        
        if let catalogImage = json[EthosConstants.catalogImage] as? String {
            self.catalogImage = catalogImage
        }
    }
}
