//
//  AlphabeticFilters.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class AlphabeticFilters : NSObject {
    var header : String
    var values = [FilterValue]()
    
    init(header: String, values: [FilterValue] = [FilterValue]()) {
        self.header = header
        self.values = values
    }
}
