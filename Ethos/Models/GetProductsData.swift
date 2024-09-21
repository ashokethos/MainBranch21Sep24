//
//  GetProductsData.swift
//  Ethos
//
//  Created by mac on 23/08/23.
//

import Foundation

class GetProductsData {
    var products: [Product]?
    var totalCount, currentPage, currentDataCount: Int?
    
    init(products: [Product]? = nil, totalCount: Int? = nil, currentPage: Int? = nil, currentDataCount: Int? = nil) {
        self.products = products
        self.totalCount = totalCount
        self.currentPage = currentPage
        self.currentDataCount = currentDataCount
    }
    
    init (json : [String : Any]) {
        if let totalCount = json[EthosConstants.totalCount] as? Int {
            self.totalCount = totalCount
        }
        
        if let currentPage = json[EthosConstants.currentPage] as? Int {
            self.currentPage = currentPage
        }
        
        if let currentDataCount = json[EthosConstants.currentDataCount] as? Int {
            self.currentDataCount = currentDataCount
        }
        
        if let products = json[EthosConstants.products] as? [[String : Any]] {
            var productArr = [Product]()
            for product in products {
                productArr.append(Product(json: product))
            }
            self.products = productArr
        }
    }
}
