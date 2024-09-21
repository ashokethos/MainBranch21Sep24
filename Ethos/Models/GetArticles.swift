//
//  GetArticles.swift
//  Ethos
//
//  Created by SoftGrid on 14/07/23.
//

import Foundation
import UIKit

class GetArticles {
    var status : Bool?
    var data : GetArticlesData?
    var error : String?
    var sql : String?
    
    init(status: Bool? = nil, data: GetArticlesData? = nil, error: String? = nil, sql: String? = nil) {
        self.status = status
        self.data = data
        self.error = error
        self.sql = sql
    }
    
    init(json : [String : Any]) {
        if let status = json [EthosConstants.status] as? Bool {
            self.status = status
        }
        
        if let error = json [EthosConstants.error] as? String {
            self.error = error
        }
        
        if let sql = json [EthosConstants.sql] as? String {
            self.sql = sql
        }
        
        if let data = json [EthosConstants.data] as? [String : Any] {
            self.data = GetArticlesData(json: data)
        }
    }
}
