//
//  CategoryNameId.swift
//  Ethos
//
//  Created by mac on 23/08/23.
//

import Foundation

struct CategoryNameId : Codable {
    var id : Int?
    var name : String?
    var image : String?
    
    enum CodingKeys: String, CodingKey {
        case id  = "category_id"
        case name
        case image
    }
}
