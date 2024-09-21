//
//  CategoryLink.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class CategoryLink  : NSObject {
    var position: Int?
    var categoryID: String?
    
    init(position: Int? = nil, categoryID: String? = nil) {
        self.position = position
        self.categoryID = categoryID
    }
    
    init(json : [String : Any]) {
        if let position = json[EthosConstants.position] as? Int {
            self.position = position
        }
        
        if let categoryID = json[EthosConstants.categoryId] as? String {
            self.categoryID = categoryID
        }
    }
    
}
