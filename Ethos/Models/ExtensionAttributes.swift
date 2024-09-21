//
//  ExtensionAttributes.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class ExtensionAttributes : NSObject {
    var categoryLinks: [CategoryLink]?
    var ethProdCustomeData: EthProdCustomeData?
    
    init(categoryLinks: [CategoryLink]? = nil, ethProdCustomeData: EthProdCustomeData? = nil) {
        self.categoryLinks = categoryLinks
        self.ethProdCustomeData = ethProdCustomeData
    }
    
    init(json : [String : Any]) {
        if let categoryLinks = json[EthosConstants.categoryLinks] as? [[String : Any]] {
            var categoryLinksArr = [CategoryLink]()
            for data in categoryLinks {
                let categoryLink = CategoryLink(json: data)
                categoryLinksArr.append(categoryLink)
            }
            self.categoryLinks = categoryLinksArr
        }
        
        if let ethProdCustomeData = json[EthosConstants.ethProdCustomeData] as? [String : Any] {
            self.ethProdCustomeData = EthProdCustomeData(json: ethProdCustomeData)
        } else if let ethProdCustomeData = json[EthosConstants.ethProdCustomeData] as? String {
            if let data = ethProdCustomeData.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                self.ethProdCustomeData = EthProdCustomeData(json: json)
            }
        }
    }
}
