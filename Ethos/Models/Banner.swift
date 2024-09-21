//
//  Banner.swift
//  Ethos
//
//  Created by mac on 31/08/23.
//

import Foundation

class Banner  : NSObject {
    
    var id: Int?
    var type, bannerType, linkType, value: String?
    var image: String?
    var title: String?
    var link: String?
    var category: String?
    var url: String?
    var sku : String?
    var bannerDescription : String?
    
    init(id: Int, type: String?, bannerType: String?, linkType: String?, value: String?, image: String?, title: String?, link: String?, category: String?, url: String?, sku: String?, description : String?) {
        self.id = id
        self.type = type
        self.bannerType = bannerType
        self.linkType = linkType
        self.value = value
        self.image = image
        self.title = title
        self.link = link
        self.category = category
        self.url = url
        self.sku = sku
        self.bannerDescription = description
    }
    
    init(json : [String : Any]) {
        if let id = json[EthosConstants.id] as? Int {
            self.id = id
        }
        
        if let type = json[EthosConstants.type] as? String {
            self.type = type
        }
        
        if let bannerType = json[EthosConstants.bannerType] as? String {
            self.bannerType = bannerType
        }
        
        if let linkType = json[EthosConstants.linkType] as? String {
            self.linkType = linkType
        }
        
        if let image = json[EthosConstants.image] as? String {
            self.image = image
        }
        
        if let title = json[EthosConstants.title] as? String {
            self.title = title
        }
        
        if let link = json[EthosConstants.link] as? String {
            self.link = link
        }
        
        if let category = json[EthosConstants.category] as? String {
            self.category = category
        }
        
        if let url = json[EthosConstants.url] as? String {
            self.url = url
        }
        
        if let sku = json[EthosConstants.sku] as? String {
            self.sku = sku
        }
        
        if let value = json[EthosConstants.value] as? String {
            self.value = value
        }
        
        if let bannerDescription = json[EthosConstants.description] as? String {
            self.bannerDescription = bannerDescription
        }
    }
}
