//
//  CustomerExtraAttributes.swift
//  Ethos
//
//  Created by mac on 22/09/23.
//

import Foundation


class CustomerExtraAttributes {
    
    var occupation, location, profileImage : String?
    var favouriteBrand = [BrandModel]()
    
    init(occupation: String? = nil, location: String? = nil, profileImage: String? = nil, favouriteBrand: [BrandModel] = []) {
        self.occupation = occupation
        self.location = location
        self.profileImage = profileImage
        self.favouriteBrand = favouriteBrand
    }
    
    init(json : [String:Any]) {
        if let occupation = json[EthosConstants.occupation] as? String {
            self.occupation = occupation
        }
        
        if let location = json[EthosConstants.location] as? String {
            self.location = location
        }
        
        if let profileImage = json[EthosConstants.profileImage] as? String {
            self.profileImage = profileImage
        }
        
        if let favouriteBrand = json[EthosConstants.favouriteBrand] as? [[String : Any]] {
            var arrFavbrand = [BrandModel]()
            
            for brand in favouriteBrand {
                if let label = brand[EthosConstants.brand] as? String, let value = brand["id"] as? Int {
                    let brandModel = BrandModel(id: value, name: label)
                    arrFavbrand.append(brandModel)
                }
            }
            
            self.favouriteBrand = arrFavbrand
        }
    }
}
