//
//  CustomCategory.swift
//  Ethos
//
//  Created by mac on 05/09/23.
//

import Foundation

class CustomCategory {
    var id: Int?
    var name: String?
    var status, order: Int?
    var description, image: String?
    
    init(id: Int?, name: String?, status: Int?, order: Int?, description: String?, image: String?) {
        self.id = id
        self.name = name
        self.status = status
        self.order = order
        self.description = description
        self.image = image
    }
    
    init(json : [String : Any]) {
        if let id = json[EthosConstants.id] as? Int {
            self.id = id
        }
        
        if let name = json[EthosConstants.name] as? String {
            self.name = name
        }
        
        if let status = json[EthosConstants.status] as? Int {
            self.status = status
        }
        
        if let order = json[EthosConstants.order] as? Int {
            self.order = order
        }
        
        if let description = json[EthosConstants.description] as? String {
            self.description = description
        }
        
        if let image = json[EthosConstants.image] as? String {
            self.image = image
        }
    }
}
