//
//  Value.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class Value : NSObject {
    var displayName, attrValID: String?
    
    init(displayName: String? = nil, attrValID: String? = nil) {
        self.displayName = displayName
        self.attrValID = attrValID
    }
    
    init(json : [String : Any]) {
        if let displayName = json[EthosConstants.displayName] as? String {
            self.displayName = displayName
        }
        
        if let attrValID = json[EthosConstants.attrValID] as? String {
            self.attrValID = attrValID
        }
    }
    
    
}
