//
//  GetArticleDetails.swift
//  Ethos
//
//  Created by mac on 04/09/23.
//

import Foundation

class GetArticleDetails : NSObject {
    var status: Bool?
    var data: GetArticleDetailsData?
    var error: String?
    
    init(status: Bool? = nil, data: GetArticleDetailsData? = nil, error: String? = nil) {
        self.status = status
        self.data = data
        self.error = error
    }
    
    init(json : [String : Any]) {
        if let status = json[EthosConstants.status] as? Bool {
            self.status = status
        }
        
        if let data = json[EthosConstants.data] as? [String : Any] {
            self.data = GetArticleDetailsData(json: data)
        }
        
        if let error = json[EthosConstants.error] as? String {
            self.error = error
        }
    }
}
