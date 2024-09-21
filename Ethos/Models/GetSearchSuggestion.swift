//
//  GetSearchSuggestion.swift
//  Ethos
//
//  Created by Ashok kumar on 12/07/24.
//

import Foundation
import UIKit

class GetSearchSuggestion: Codable {
    
    var status: Bool?
    var data: [GetSearchSuggestionModel]?
    
    init(status: Bool? = nil, data: [GetSearchSuggestionModel]? = nil) {
        self.status = status
        self.data = data
    }
    
    init(json: [String: Any]) {
        self.status = json["status"] as? Bool
        
        if let dataArray = json["data"] as? [[String: Any]] {
            self.data = dataArray.map { GetSearchSuggestionModel(json: $0) }
        }
    }
}

class GetSearchSuggestionModel: Codable {
    var title: String?
    var id: String?
    var sku: String?
    var type: String?
    var filters: GetSearchSuggestionFiltersModel?
    
    init(title: String? = nil, id: String? = nil, sku: String? = nil, type: String? = nil, filters: GetSearchSuggestionFiltersModel? = nil) {
        self.title = title
        self.id = id
        self.sku = sku
        self.type = type
        self.filters = filters
    }
    
    init(json: [String: Any]) {
        self.title = json["title"] as? String
        self.id = json["id"] as? String
        self.sku = json["sku"] as? String
        self.type = json["type"] as? String
        
        if let filtersJSON = json["filters"] as? [String: Any] {
            self.filters = GetSearchSuggestionFiltersModel(json: filtersJSON)
        }
    }
}


class GetSearchSuggestionFiltersModel: Codable {
    
    var attrCode: String?
    var attrName: String?
    var value: [GetSearchSuggestionFiltersValueModel]?
    var categoryId: [String]?
    
    init(attrCode: String? = nil, attrName: String? = nil, value: [GetSearchSuggestionFiltersValueModel]? = nil, categoryId: [String]? = nil) {
        self.attrCode = attrCode
        self.attrName = attrName
        self.value = value
        self.categoryId = categoryId
    }
    
    init(json: [String: Any]) {
        self.attrCode = json["attr_code"] as? String
        self.attrName = json["attr_name"] as? String
        
        if let valueArray = json["value"] as? [[String: Any]] {
            self.value = valueArray.map { GetSearchSuggestionFiltersValueModel(json: $0) }
        }
        
        if let categoryIdArray = json["category_id"] as? [String] {
            self.categoryId = categoryIdArray
        }
        
        if let categoryIdArray = json["category_id"] as? [Int] {
            self.categoryId = categoryIdArray.map { String($0)}
        }
    }
}

class GetSearchSuggestionFiltersValueModel: Codable {
    
    var attrValueId: String?
    var attrValueName: String?
    
    init(attrValueId: String? = nil, attrValueName: String? = nil) {
        self.attrValueId = attrValueId
        self.attrValueName = attrValueName
    }
    
    init(json: [String: Any]) {
        if let attrValueId = json["attr_value_id"] as? String {
            self.attrValueId = attrValueId
        }
        if let attrValueId = json["attr_value_id"] as? Int {
            self.attrValueId = String(attrValueId)
        }
        self.attrValueName = json["attr_value_name"] as? String
    }
}
