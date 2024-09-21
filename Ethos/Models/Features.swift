//
//  Features.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class Features : NSObject {
    var attrSetID, attrID: String?
    var displayName: String?
    var type: String?
    var value: [Value]?
    
    init(attrSetID: String? = nil, attrID: String? = nil, displayName: String? = nil, type: String? = nil, value: [Value]? = nil) {
        self.attrSetID = attrSetID
        self.attrID = attrID
        self.displayName = displayName
        self.type = type
        self.value = value
    }
    
    init(json : [String : Any]) {
        if let attrSetID = json[EthosConstants.attrSetID] as? String {
            self.attrSetID = attrSetID
        }
        
        if let attrID = json[EthosConstants.attrId] as? String {
            self.attrID = attrID
        }
        
        if let displayName = json[EthosConstants.displayName] as? String {
            self.displayName = displayName
        }
        
        if let type = json[EthosConstants.type] as? String {
            self.type = type
        }
        
        if let value = json[EthosConstants.value] as? [[String : Any]] {
            var values = [Value]()
            for v in value {
                values.append(Value(json: v))
            }
            
            self.value = values
        }
        
    }
}
