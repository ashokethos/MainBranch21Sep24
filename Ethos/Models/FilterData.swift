//
//  FilterData.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class FilterData : NSObject {
    
    var attributes : FilterDataAttributes?
    var child : FilterData?
    
    init(attributes: FilterDataAttributes? = nil, child: FilterData? = nil) {
        self.attributes = attributes
        self.child = child
    }
    
    func getDictionary() -> [String : Any] {
        var dictionary = [String : Any]()
        
        if let attributes = self.attributes {
            dictionary[EthosConstants.attr] = attributes.getDictionary()
        }
        
        if let child = self.child {
            dictionary[EthosConstants.filters] = child.getDictionary()
        }
        
        return dictionary
    }
}
