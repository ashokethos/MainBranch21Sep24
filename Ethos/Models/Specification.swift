//
//  Specification.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class Specification : NSObject {
    var brand: String?
    var collection, series: String?
    var model: String?
    
    init(brand: String? = nil, collection: String? = nil, series: String? = nil, model: String? = nil) {
        self.brand = brand
        self.collection = collection
        self.series = series
        self.model = model
    }
    
    init(json : [String : Any]) {
        if let brand = json[EthosConstants.brand] as? String {
            self.brand = brand
        }
        
        if let collection = json[EthosConstants.collection] as? String {
            self.collection = collection
        }
        
        if let series = json[EthosConstants.series] as? String {
            self.series = series
        }
        
        if let model = json[EthosConstants.model] as? String {
            self.model = model
        }
    }
}
