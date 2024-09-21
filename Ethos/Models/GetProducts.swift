//
//  GetProducts.swift
//  Ethos
//
//  Created by mac on 23/08/23.
//


import Foundation

struct GetProducts {
    var status: Bool?
    var data: GetProductsData?
    
    init(status: Bool, data: GetProductsData) {
        self.status = status
        self.data = data
    }
    
    init(json : [String : Any]) {
        if let status = json[EthosConstants.status] as? Bool {
            self.status = status
        }
        
        if let data = json[EthosConstants.data] as? [String : Any] {
            self.data = GetProductsData(json: data)
        }
    }
}
