//
//  FormBrandsData.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class FormBrandsData : NSObject {
    var status: Bool?
    var brands: [FormBrand] = []

    init(json : [String : Any]) {
        if let status = json[EthosConstants.status] as? Bool {
            self.status = status
        }
        
        if let brands = json[EthosConstants.brands] as? [String : String] {
            var arrBrands = [FormBrand]()
            for (key, value) in brands {
                let brand = FormBrand(label: value, value: key)
                arrBrands.append(brand)
            }
            self.brands = arrBrands.sorted(by: { b1, b2 in
                b2.label?.lowercased() ?? "" > b1.label?.lowercased() ??  ""
            })
        }
    }
}
