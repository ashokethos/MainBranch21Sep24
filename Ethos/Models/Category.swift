//
//  Category.swift
//  Ethos
//
//  Created by mac on 28/07/23.
//

import Foundation
import UIKit


struct Category: Codable {
    var id, parentID: Int?
    var name: String?
    var isActive: Bool?
    var position, level, productCount: Int?
    var childrenData: [Category]?

    enum CodingKeys: String, CodingKey {
        case id
        case parentID = "parent_id"
        case name
        case isActive = "is_active"
        case position, level
        case productCount = "product_count"
        case childrenData = "children_data"
    }
}



