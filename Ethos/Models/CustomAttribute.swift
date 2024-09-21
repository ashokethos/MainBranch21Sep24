//
//  CustomAttribute.swift
//  Ethos
//
//  Created by mac on 26/08/23.
//

import Foundation

class CustomAttribute {
    var attributeCode, value: String?
    
    init(attributeCode: String? = nil, value: String? = nil) {
        self.attributeCode = attributeCode
        self.value = value
    }
    
    init(json : [String : Any]) {
        if let attributeCode = json[EthosConstants.attributeCode] as? String {
            self.attributeCode = attributeCode
        }
        
        if let value = json[EthosConstants.value] as? String {
            self.value = value
        }
    }
}
