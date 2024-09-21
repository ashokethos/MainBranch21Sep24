//
//  EthProdCustomeData.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class EthProdCustomeData : NSObject {
    var sku, pid: String?
    var url: String?
    var brand: String?
    var isSaleable, isBuyNow: Int?
    var buttonText: String?
    var collection, series, collectionDescription: String?
    var showVideo: Bool?
    var productVideo: String?
    var productVideos : [ProductVideo] = []
    var seriesVideo, collectionVideo: String?
    var calibreImage: String?
    var calibreDescription: String?
    var movement: [String : String]?
    var attributes: Attributes?
    var attributesDictionary : [String : Any]?
    var movementKey: [String]?
    var caseKey: [String]?
    var dialKey: [String]?
    var strapKey: [String]?
    var otherKey: [String]?
    var showMovement : Bool? = false
    var productName : String?
    var showFeaturedWatch : Bool?
    var favreLeubaData : FavreLeubaData?
    var watchConditionDescription : String?
    var specificationAttributes : [String]?
    var watchCondition : String?
    var purchaseYear : String?
    var warrantyCard : String?
    var size : String?
    var serviceRecord : String?
    var watchBox : String?
    var price : Int?
    var images : ProductImageData?
    var hidePrice : Bool = false
    var collectionImage : String?
    var showEditosNote : Bool?
    var editorHeading : String?
    var editorDescription : String?
    
    init(json : [String : Any]) {
        
        if let productVideos = json[EthosConstants.productVideos] as? [[String : Any]] {
            var arrProductVideos = [ProductVideo]()
            for video in productVideos {
                let video = ProductVideo(json: video)
                arrProductVideos.append(video)
            }
            self.productVideos = arrProductVideos
        }
        
        if let price = json[EthosConstants.price] as? Int {
            self.price = price
        }
        
        if let collectionImage = json[EthosConstants.collectionImage] as? String {
            self.collectionImage = collectionImage
        }
        
        if let sku = json[EthosConstants.sku] as? String {
            self.sku = sku
        }
        
        if let pid = json[EthosConstants.pid] as? String {
            self.pid = pid
        }
        
        if let url = json[EthosConstants.url] as? String {
            self.url = url
        }
        
        if let brand = json[EthosConstants.brand] as? String {
            self.brand = brand
        }
        
        if let isSaleable = json[EthosConstants.isSaleable] as? Int {
            self.isSaleable = isSaleable
        }
        
        if let isBuyNow = json[EthosConstants.isBuyNow] as? Int {
            self.isBuyNow = isBuyNow
        }
        
        if let specificationAttributes = json[EthosConstants.specificationAttributes] as? [String] {
            self.specificationAttributes = specificationAttributes
        }
        
        if let buttonText = json[EthosConstants.buttonText] as? String {
            self.buttonText = buttonText
        } else if let buttonText = json[EthosConstants.button_text] as? String {
            self.buttonText = buttonText
        }
        
        if let collection = json[EthosConstants.collection] as? String {
            self.collection = collection
        }
        
        if let series = json[EthosConstants.series] as? String {
            self.series = series
        }
        
        if let collectionDescription = json[EthosConstants.collectionDescription] as? String {
            self.collectionDescription = collectionDescription
        }
        
        if let showVideo = json[EthosConstants.showVideo] as? Int {
            if showVideo == 1 {
                self.showVideo = true
            } else {
                self.showVideo = false
            }
        }
        
        if let productVideo = json[EthosConstants.productVideo] as? String {
            self.productVideo = productVideo
        }
        
        if let seriesVideo = json[EthosConstants.seriesVideo] as? String {
            self.seriesVideo = seriesVideo
        }
        
        if let collectionVideo = json[EthosConstants.collectionVideo] as? String {
            self.collectionVideo = collectionVideo
        }
        
        if let calibreImage = json[EthosConstants.calibreImage] as? String {
            self.calibreImage = calibreImage
        }
        
        if let movement = json[EthosConstants.movement] as? [String : String] {
            self.movement = movement
        }
        
        if let attributes = json[EthosConstants.attributes] as? [String : Any] {
            self.attributes = Attributes(json: attributes)
            self.attributesDictionary = attributes
        }
        
        if let movementKey = json[EthosConstants.movementKey] as? [String] {
            self.movementKey = movementKey
        }
        
        if let strapKey = json[EthosConstants.strapKey] as? [String] {
            self.strapKey = strapKey
        }
        
        if let caseKey = json[EthosConstants.caseKey] as? [String] {
            self.caseKey = caseKey
        }
        
        if let dialKey = json[EthosConstants.dialKey] as? [String] {
            self.dialKey = dialKey
        }
        
        if let otherKey = json[EthosConstants.otherKey] as? [String] {
            self.otherKey = otherKey
        }
        
        if let showMovement = json[EthosConstants.showMovement] as? String {
            if showMovement == EthosConstants.yes {
                self.showMovement = true
            } else {
                self.showMovement = false
            }
        }
        
        if let productName = json[EthosConstants.productname] as? String {
            self.productName = productName
        }
        
        if let showFeaturedWatch = json[EthosConstants.showFeaturedWatch] as? String {
            if showFeaturedWatch == EthosConstants.yes {
                self.showFeaturedWatch = true
            } else {
                self.showFeaturedWatch = false
            }
        }
        
        if let favreLeubaData = json[EthosConstants.favreLeubaData] as? [String : Any] {
            self.favreLeubaData = FavreLeubaData(json: favreLeubaData)
        }
        
        if let watchCondition = json[EthosConstants.watchCondition] as? String {
            self.watchCondition = watchCondition
        }
        
        if let watchConditionDescription = json[EthosConstants.watchConditionDescription] as? String {
            self.watchConditionDescription = watchConditionDescription
        }
        
        if let purchaseYear = json[EthosConstants.purchaseYear] as? String {
            self.purchaseYear = purchaseYear
        }
        
        if let calibreDescription = json[EthosConstants.calibreDescription] as? String {
            self.calibreDescription = calibreDescription
        }
        
        if let warrantyCard = json[EthosConstants.warrantyCard] as? String {
            self.warrantyCard = warrantyCard
        }
        
        if let size = json[EthosConstants.caseSize] as? String {
            self.size = size
        }
        
        if let serviceRecord = json[EthosConstants.serviceRecord] as? String {
            self.serviceRecord = serviceRecord
        }
        
        if let watchBox = json[EthosConstants.watchBox] as? String {
            self.watchBox = watchBox
        }
        
        if let images = json[EthosConstants.images] as? [String : Any] {
            self.images = ProductImageData(json: images)
        }
        
        if let hidePrice = json[EthosConstants.hidePrice] as? String {
            if hidePrice.lowercased() == EthosConstants.no {
                self.hidePrice = false
            } else if hidePrice.lowercased() == EthosConstants.yes {
                self.hidePrice = true
            }
        }
        
        if let showEditosNote = json[EthosConstants.showEditosNote] as? Bool {
            self.showEditosNote = showEditosNote
        }
        
        if let editorHeading = json[EthosConstants.editorHeading] as? String {
            self.editorHeading = editorHeading
        }
        
        if let editorDescription = json[EthosConstants.editorDescription] as? String {
            self.editorDescription = editorDescription
        }
    }
    
    init(sku: String? = nil, pid: String? = nil, url: String? = nil, brand: String? = nil, isSaleable: Int? = nil, isBuyNow: Int? = nil, buttonText: String? = nil, collection: String? = nil, series: String? = nil, collectionDescription: String? = nil, showVideo: Bool? = nil, productVideo: String? = nil, seriesVideo: String? = nil, collectionVideo: String? = nil, calibreImage: String? = nil, calibreDescription: String? = nil, movement: [String : String]? = nil, attributes: Attributes? = nil, movementKey: [String]? = nil, caseKey: [String]? = nil, dialKey: [String]? = nil, strapKey: [String]? = nil, otherKey: [String]? = nil, productName : String? = nil, images : ProductImageData?, hidePrice : Bool = false, price : Int? = nil, showEditosNote: Bool? = nil, editorHeading: String? = nil, editorDescription: String? = nil) {
        self.sku = sku
        self.pid = pid
        self.url = url
        self.brand = brand
        self.isSaleable = isSaleable
        self.isBuyNow = isBuyNow
        self.buttonText = buttonText
        self.collection = collection
        self.series = series
        self.collectionDescription = collectionDescription
        self.showVideo = showVideo
        self.productVideo = productVideo
        self.seriesVideo = seriesVideo
        self.collectionVideo = collectionVideo
        self.calibreImage = calibreImage
        self.calibreDescription = calibreDescription
        self.movement = movement
        self.attributes = attributes
        self.movementKey = movementKey
        self.caseKey = caseKey
        self.dialKey = dialKey
        self.strapKey = strapKey
        self.otherKey = otherKey
        self.productName = productName
        self.images = images
        self.hidePrice = hidePrice
        self.price = price
        self.showEditosNote = showEditosNote
        self.editorHeading = editorHeading
        self.editorDescription = editorDescription
    }
}
