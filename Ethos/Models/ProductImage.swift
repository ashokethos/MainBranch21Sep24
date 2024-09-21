//
//  ProductImage.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class ProductImage {
    
    var image : String?
    var order : Int?
    
    init(image: String? = nil, order: Int? = nil) {
        self.image = image
        self.order = order
    }
    
    init(json : [String : Any]) {
        if let image = json[EthosConstants.image] as? String {
            self.image = image
        }
        
        if let order = json[EthosConstants.order] as? Int {
            self.order = order
        }
    }
    
}
