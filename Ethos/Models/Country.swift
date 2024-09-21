//
//  Country.swift
//  Ethos
//
//  Created by mac on 01/08/23.
//

import Foundation
import UIKit

struct Country: Codable {
    var name: String?
    var dialCode : String?
    var code: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case dialCode = "dial_code"
        case code
    }
}
