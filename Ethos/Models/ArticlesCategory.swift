//
//  ArticlesCategory.swift
//  Ethos
//
//  Created by mac on 31/08/23.
//

import Foundation

class ArticlesCategory : NSObject {
    
    var id: Int?
    var name, categoryDescription: String?
    var image: String?
    
    init(id: Int?, name: String?, categoryDescription: String?, image: String?) {
        self.id = id
        self.name = name
        self.categoryDescription = categoryDescription
        self.image = image
    }
    
    init(json : [String : Any]) {
        if let id = json[EthosConstants.id] as? Int {
            self.id = id
        }
        
        if let name = json[EthosConstants.name] as? String {
            self.name = name
        }
        
        if let categoryDescription = json[EthosConstants.description] as? String {
            self.categoryDescription = categoryDescription
        }
        
        if let image = json[EthosConstants.image] as? String {
            self.image = image
        }
    }
}
