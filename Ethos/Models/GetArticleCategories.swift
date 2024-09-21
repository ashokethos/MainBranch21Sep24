//
//  GetArticleCategories.swift
//  Ethos
//
//  Created by mac on 31/08/23.
//

import Foundation

class GetArticleCategories : NSObject {
    var status: Bool?
    var data: GetArticleCategoriesData?
    var error: String?
    
    init(status: Bool?, data: GetArticleCategoriesData?, error: String?) {
        self.status = status
        self.data = data
        self.error = error
    }
    
    init(json : [String : Any]) {
        if let status = json[EthosConstants.status] as? Bool {
            self.status = status
        }
        
        if let data = json[EthosConstants.data] as? [String : Any] {
            self.data = GetArticleCategoriesData(json: data)
        }
        
        if let error = json[EthosConstants.error] as? String {
            self.error = error
        }
        
    }
    
}
