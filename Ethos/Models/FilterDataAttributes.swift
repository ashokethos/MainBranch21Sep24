//
//  FilterDataAttributes.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class FilterDataAttributes : NSObject {
    
    var attributeCode : String?
    var attributeValues : [String]?
    
    init(attributeCode: String, attributeValues: [String]) {
        self.attributeCode = attributeCode
        self.attributeValues = attributeValues
    }
    
    func getDictionary() -> [String : Any] {
        var dictionary = [String : Any]()
        
        if let attributeCode = self.attributeCode {
            dictionary[EthosConstants.code] = attributeCode
        }
        
        if let attributeValues = self.attributeValues {
            dictionary[EthosConstants.values] = attributeValues
        }
        
        return dictionary
    }
}
