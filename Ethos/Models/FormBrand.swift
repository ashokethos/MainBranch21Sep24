//
//  FormBrands.swift
//  Ethos
//
//  Created by mac on 02/02/24.
//

import Foundation

class FormBrand : NSObject {
    var label: String?
    var value: String?
    
    init(label: String, value: String) {
        self.label = label
        self.value = value
    }
}
