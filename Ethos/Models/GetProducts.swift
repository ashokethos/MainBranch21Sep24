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
    var search_input_data: SearchInputData?
    
    init(status: Bool, data: GetProductsData, search_input_data: SearchInputData?) {
        self.status = status
        self.data = data
        self.search_input_data = search_input_data
    }
    
    init(json : [String : Any]) {
        if let status = json[EthosConstants.status] as? Bool {
            self.status = status
        }
        
        if let data = json[EthosConstants.data] as? [String : Any] {
            self.data = GetProductsData(json: data)
        }
        
        if let searchInputData = json[EthosConstants.searchInputData] as? [String : Any] {
            self.search_input_data = SearchInputData(json: searchInputData)
        }
    }
}

struct SearchInputData {
    var productString: String?
    var filter: FilterModel?
    
    init(productString: String, filter: FilterModel) {
        self.productString = productString
        self.filter = filter
    }
    
    init(json : [String : Any]) {
        if let productString = json[EthosConstants.productString] as? String {
            self.productString = productString
        }
        
        if let filter = json[EthosConstants.filter] as? [String : Any] {
            self.filter = FilterModel(json: filter)
        }
    }
}

struct FilterNewCategory{
    var attr_code: String?
    var attr_name: String?
    
    init(attr_code: String, attr_name: String) {
        self.attr_code = attr_code
        self.attr_name = attr_name
    }
    
    init(json : [String : Any]) {
        if let attrCode = json[EthosConstants.attrCode] as? String {
            self.attr_code = attrCode
        }
        
        if let attrName = json[EthosConstants.attrName] as? String {
            self.attr_name = attrName
        }
        
//        if let data = json[EthosConstants.data] as? [String : Any] {
//            self.data = GetProductsData(json: data)
//        }
    }
}
