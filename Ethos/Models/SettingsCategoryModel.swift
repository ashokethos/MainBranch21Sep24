//
//  SettingsCategoryModel.swift
//  Ethos
//
//  Created by Softgrid on 29/07/24.
//

import Foundation

class SettingsCategory : NSObject {
    
    var categoryId : Int?
    var appliedFilters : [FilterModel] = []
    
    init(categoryId: Int? = nil) {
        self.categoryId = categoryId
    }
    
    init(json : [String: Any]) {
        
        if let categoryId = json["category_id"] as? Int {
            self.categoryId = categoryId
        }
        
        
        
        if let appliedFilters = json["applied_filters"] as? [[String : Any]] {
            var arrFilters = [FilterModel]()
            for appliedFilter in appliedFilters {
                let filter = FilterModel(json: appliedFilter)
                arrFilters.append(filter)
            }
            self.appliedFilters = arrFilters
        }
        
        
        
    }
    
    
}
