//
//  Product.swift
//  Ethos
//
//  Created by mac on 23/08/23.
//


import Foundation

class Product : NSObject {
    
    var id, prod_id: Int?
    var sku, name, brand, prod_brand, gender, url, imgUrl, title, isSalable, prod_collection: String?
    var attributeSetID, price, status, visibility: Int?
    var typeID: String?
    var createdAt: String?
    var updatedAt: String?
    var weight: Double?
    var extensionAttributes: ExtensionAttributes?
    var tierPrices: [TierPrice]?
    var relatedStories: RelatedStories?
    var movement: [String : String]?
    var video: String?
    var aboutCollection: String?
    var specifications: [Specification]?
    var assets: [ProductAsset]?
    var currency: String?
    var forPreOwned : Bool = false
    var recentDate : Date?
    
    
    init(id: Int? = nil, prod_id: Int? = nil, sku: String? = nil, name: String? = nil, brand: String? = nil, prod_brand: String? = nil, gender: String? = nil, url: String? = nil, imgUrl: String? = nil, title: String? = nil, isSalable: String? = nil, prod_collection: String? = nil, attributeSetID: Int? = nil, price: Int? = nil, status: Int? = nil, visibility: Int? = nil, typeID: String? = nil, createdAt: String? = nil, updatedAt: String? = nil, weight: Double? = nil, extensionAttributes: ExtensionAttributes? = nil, tierPrices: [TierPrice]? = nil, relatedStories: RelatedStories? = nil, movement: [String : String]? = nil, video: String? = nil, aboutCollection: String? = nil, specifications: [Specification]? = nil, assets: [ProductAsset]? = nil, currency: String? = nil) {
        self.id = id
        self.prod_id = prod_id
        self.sku = sku
        self.name = name
        self.brand = brand
        self.prod_brand = prod_brand
        self.gender = gender
        self.title = title
        self.isSalable = isSalable
        self.prod_collection = prod_collection
        self.attributeSetID = attributeSetID
        self.price = price
        self.status = status
        self.visibility = visibility
        self.typeID = typeID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.weight = weight
        self.extensionAttributes = extensionAttributes
        self.tierPrices = tierPrices
        self.relatedStories = relatedStories
        self.movement = movement
        self.video = video
        self.aboutCollection = aboutCollection
        self.specifications = specifications
        self.assets = assets
        self.currency = currency
    }
    
    init(json : [String : Any]) {
        
        if let id = json[EthosConstants.id] as? Int {
            self.id = id
        }
        
        if let prod_id = json[EthosConstants.prod_id] as? Int {
            self.prod_id = prod_id
        }
        
        if let sku = json[EthosConstants.sku] as? String {
            self.sku = sku
        }
        
        if let prod_brand = json[EthosConstants.prod_brand] as? String {
            self.prod_brand = prod_brand
        }
        
        if let gender = json[EthosConstants.gender] as? String {
            self.gender = gender
        }
        
        if let title = json[EthosConstants.title] as? String {
            self.title = title
        }
        
        if let isSalable = json[EthosConstants.isSalable] as? String {
            self.isSalable = isSalable
        }
        
        if let prod_collection = json[EthosConstants.prod_collection] as? String {
            self.prod_collection = prod_collection
        }
        
        if let url = json[EthosConstants.url] as? String {
            self.url = url
        }
        
        if let imgUrl = json[EthosConstants.imgUrl] as? String {
            self.imgUrl = imgUrl
        }
        
        if let price = json[EthosConstants.price] as? Int {
            self.price = price
        }
        
        if let attributeSetID = json[EthosConstants.attributeSetID] as? Int {
            self.attributeSetID = attributeSetID
        }
        
        if let price = json[EthosConstants.price] as? Int {
            self.price = price
        }
        
        if let status = json[EthosConstants.status] as? Int {
            self.status = status
        }
        
        if let typeID = json[EthosConstants.typeID] as? String {
            self.typeID = typeID
        }
        
        if let createdAt = json[EthosConstants.createdAt] as? String {
            self.createdAt = createdAt
        }
        
        if let updatedAt = json[EthosConstants.updatedAt] as? String {
            self.updatedAt = updatedAt
        }
        
        if let weight = json[EthosConstants.weight] as? Double {
            self.weight = weight
        }
        
        if let extensionAttributes = json[EthosConstants.extensionAttributes] as? [String : Any] {
            self.extensionAttributes = ExtensionAttributes(json: extensionAttributes)
        }
        
        if json[EthosConstants.tierPrices] is [[String : Any]] {
            var tierPrices = [TierPrice]()
            for _ in tierPrices {
                let price = TierPrice()
                tierPrices.append(price)
            }
            self.tierPrices = tierPrices
        }
        
        if let relatedStories = json[EthosConstants.relatedStories] as? [String : Any] {
            self.relatedStories = RelatedStories(json: relatedStories)
        }
        
        if let movement = json[EthosConstants.movement] as? [String : String] {
            self.movement = movement
        }
        
        if let video = json[EthosConstants.video] as? String {
            self.video = video
        }
        
        if let aboutCollection = json[EthosConstants.aboutCollection] as? String {
            self.aboutCollection = aboutCollection
        }
        
        if let specifications = json[EthosConstants.specifications] as? [[String : Any]] {
            var specificationArr = [Specification]()
            
            for json in specifications {
                let specification = Specification(json: json)
                specificationArr.append(specification)
            }
            
            self.specifications = specificationArr
        }
        
        if let assets = json[EthosConstants.assets] as?  [[String : Any]] {
            var assetArr = [ProductAsset]()
            
            for json in assets {
                let asst = ProductAsset(json: json)
                assetArr.append(asst)
            }
            
            self.assets = assetArr
        }
        
        if let currency = json[EthosConstants.currency] as? String {
            self.currency = currency
        }
        
        if let name = json[EthosConstants.name] as? String {
            self.name = name
        }
        
        if let brand = json[EthosConstants.brand] as? String {
            self.brand = brand
        }
        
        if let visibility = json[EthosConstants.visibility] as? Int {
            self.visibility = visibility
        }
        
    }
}
