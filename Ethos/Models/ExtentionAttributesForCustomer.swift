//
//  ExtentionAttributesForCustomer.swift
//  Ethos
//
//  Created by mac on 26/08/23.
//

import Foundation

class ExtentionAttributesForCustomer {
    var isSubscribed: Bool?

    init(isSubscribed: Bool?) {
        self.isSubscribed = isSubscribed
    }
    
    init(json : [String : Any]){
        if let isSubscribed = json[EthosConstants.isSubscribed] as? Bool {
            self.isSubscribed = isSubscribed
        }
    }
}
