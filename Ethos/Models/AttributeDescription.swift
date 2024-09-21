//
//  AttributeDescription.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class AttributeDescription : NSObject {
    var attrSetID, attrID: String?
    var displayName: String?
    var type: String?
    var value: Value?
    var values : [Value]?
    
    init(attrSetID: String? = nil, attrID: String? = nil, displayName: String? = nil, type: String? = nil, value: Value? = nil) {
        self.attrSetID = attrSetID
        self.attrID = attrID
        self.displayName = displayName
        self.type = type
        self.value = value
    }
    
    init(json : [String : Any]){
        
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
        
        if let value = json[EthosConstants.value] as? [String : Any] {
            self.value = Value(json: value)
        } else if let values = json[EthosConstants.value] as? [[String : Any]] {
            var arrVal = [Value]()
            for value in values {
                let val = Value(json: value)
                arrVal.append(val)
            }
            self.values = arrVal.sorted(by: { v1, v2 in
                (v2.displayName ?? "").lowercased() > (v1.displayName ?? "").lowercased()
            })
        }
    }
}
