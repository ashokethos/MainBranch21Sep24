//
//  Attributes.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class Attributes : NSObject {
    var name, sku: AttributeDescription?
    var gtin: AttributeDescription?
    var manufacturer: AttributeDescription?
    var watchType: AttributeDescription?
    var family: AttributeDescription?
    var subBrand: AttributeDescription?
    var categoryType: AttributeDescription?
    var features: Features?
    var createdAt, updatedAt: AttributeDescription?
    var caseSize: AttributeDescription?
    var casesize: AttributeDescription?
    var caseShape, material, powerReserve, movement: AttributeDescription?
    var straptype, interchangeableStrap, calibre, diameter: AttributeDescription?
    var caliberBase, calibreDate, calibreChronograph, caseBack: AttributeDescription?
    var dialcolor, hands: AttributeDescription?
    var stockstatus: AttributeDescription?
    var indexes, frequency, gender, ecomstock: AttributeDescription?
    var waterResistance: AttributeDescription?
    var glass: AttributeDescription?
    var warrantyPeriod, limitedEdition, hidePrice, series: AttributeDescription?
    var strapColor, bezel, preciousStone, claspType: AttributeDescription?
    var warrantyText, customname, lugWidth, productvideo: AttributeDescription?
    var luminosity, jewels: AttributeDescription?
    
    init(json : [String : Any]) {
        if let name = json[EthosConstants.name] as? [String : Any] {
            self.name = AttributeDescription(json: name)
        }
        
        if let sku = json[EthosConstants.sku] as? [String : Any] {
            self.sku = AttributeDescription(json: sku)
        }
        
        if let gtin = json[EthosConstants.gtin] as? [String : Any] {
            self.gtin = AttributeDescription(json: gtin)
        }
        
        if let manufacturer = json[EthosConstants.manufacturer] as? [String : Any] {
            self.manufacturer = AttributeDescription(json: manufacturer)
        }
        
        if let watchType = json[EthosConstants.watchType] as? [String : Any] {
            self.watchType = AttributeDescription(json: watchType)
        }
        
        if let family = json[EthosConstants.family] as? [String : Any] {
            self.family = AttributeDescription(json: family)
        }
        
        if let subBrand = json[EthosConstants.subBrand] as? [String : Any] {
            self.subBrand = AttributeDescription(json: subBrand)
        }
        
        if let categoryType = json[EthosConstants.categoryType] as? [String : Any] {
            self.categoryType = AttributeDescription(json: categoryType)
        }
        
        if let features = json[EthosConstants.features]  as? [String : Any] {
            self.features = Features(json: features)
        }
        
        if let createdAt = json[EthosConstants.createdAt] as? AttributeDescription {
            self.createdAt = createdAt
        }
        
        if let updatedAt = json[EthosConstants.updatedAt] as? [String : Any] {
            self.updatedAt = AttributeDescription(json: updatedAt)
        }
        
        if let caseSize = json[EthosConstants.caseSize] as? [String : Any] {
            self.caseSize = AttributeDescription(json: caseSize)
        }
        
        if let casesize = json[EthosConstants.casesize] as? [String : Any] {
            self.casesize = AttributeDescription(json: casesize)
        }
        
        if let caseShape = json[EthosConstants.caseShape] as? [String : Any] {
            self.caseShape = AttributeDescription(json: caseShape)
        }
        
        if let material = json[EthosConstants.material] as? [String : Any] {
            self.material = AttributeDescription(json: material)
        }
        
        if let powerReserve = json[EthosConstants.powerReserve] as? [String : Any] {
            self.powerReserve = AttributeDescription(json: powerReserve)
        }
        
        if let movement = json[EthosConstants.movement] as? [String : Any] {
            self.movement = AttributeDescription(json: movement)
        }
        
        if let straptype = json[EthosConstants.straptype] as? [String : Any] {
            self.straptype = AttributeDescription(json: straptype)
        }
        
        if let interchangeableStrap = json[EthosConstants.interchangeableStrap] as? [String : Any] {
            self.interchangeableStrap = AttributeDescription(json: interchangeableStrap)
        }
        
        if let calibre = json[EthosConstants.calibre] as? [String : Any] {
            self.calibre = AttributeDescription(json: calibre)
        }
        
        if let diameter = json[EthosConstants.diameter] as? [String : Any] {
            self.diameter = AttributeDescription(json: diameter)
        }
        
        if let caliberBase = json[EthosConstants.caliberBase] as? [String : Any] {
            self.caliberBase = AttributeDescription(json: caliberBase)
        }
        
        if let calibreDate = json[EthosConstants.calibreDate] as? [String : Any] {
            self.calibreDate = AttributeDescription(json: calibreDate)
        }
        
        if let calibreChronograph = json[EthosConstants.calibreChronograph] as? [String : Any] {
            self.calibreChronograph = AttributeDescription(json: calibreChronograph)
        }
        
        if let caseBack = json[EthosConstants.caseBack] as? [String : Any] {
            self.caseBack = AttributeDescription(json: caseBack)
        }
        
        if let dialcolor = json[EthosConstants.dialcolor] as? [String : Any] {
            self.dialcolor = AttributeDescription(json: dialcolor)
        }
        
        
        if let hands = json[EthosConstants.hands] as? [String : Any] {
            self.hands = AttributeDescription(json: hands)
        }
        
        if let stockstatus = json[EthosConstants.stockstatus] as? [String : Any] {
            self.stockstatus = AttributeDescription(json: stockstatus)
        }
        
        if let indexes = json[EthosConstants.indexes] as? [String : Any] {
            self.indexes = AttributeDescription(json: indexes)
        }
        
        if let frequency = json[EthosConstants.frequency] as? [String : Any] {
            self.frequency = AttributeDescription(json: frequency)
        }
        
        if let gender = json[EthosConstants.gender] as? [String : Any] {
            self.gender = AttributeDescription(json: gender)
        }
        
        if let ecomstock = json[EthosConstants.ecomstock] as? [String : Any] {
            self.ecomstock = AttributeDescription(json: ecomstock)
        }
        
        if let waterResistance = json[EthosConstants.waterResistance] as?  [String : Any] {
            self.waterResistance = AttributeDescription(json: waterResistance)
        }
        
        if let glass = json[EthosConstants.glass] as? [String : Any] {
            self.glass = AttributeDescription(json: glass)
        }
        
        if let warrantyPeriod = json[EthosConstants.warrantyPeriod] as? [String : Any] {
            self.warrantyPeriod = AttributeDescription(json: warrantyPeriod)
        }
        
        if let limitedEdition = json[EthosConstants.limitedEdition] as? [String : Any] {
            self.limitedEdition = AttributeDescription(json: limitedEdition)
        }
        
        if let hidePrice = json[EthosConstants.hidePrice] as? [String : Any] {
            self.hidePrice = AttributeDescription(json: hidePrice)
        }
        
        if let series = json[EthosConstants.series] as? [String : Any] {
            self.series = AttributeDescription(json: series)
        }
        
        if let strapColor = json[EthosConstants.strapColor] as? [String : Any] {
            self.strapColor = AttributeDescription(json: strapColor)
        }
        
        if let bezel = json[EthosConstants.bezel] as? [String : Any] {
            self.bezel = AttributeDescription(json: bezel)
        }
        
        if let preciousStone = json[EthosConstants.preciousStone] as? [String : Any] {
            self.preciousStone = AttributeDescription(json: preciousStone)
        }
        
        if let claspType = json[EthosConstants.claspType] as? [String : Any] {
            self.claspType = AttributeDescription(json: claspType)
        }
        
        if let warrantyText = json[EthosConstants.warrantyText] as? [String : Any] {
            self.warrantyText = AttributeDescription(json: warrantyText)
        }
        
        if let customname = json[EthosConstants.customname] as? [String : Any] {
            self.customname = AttributeDescription(json: customname)
        }
        
        if let lugWidth = json[EthosConstants.lugWidth] as? [String : Any] {
            self.lugWidth = AttributeDescription(json: lugWidth)
        }
        
        if let productvideo = json[EthosConstants.productvideo] as? [String : Any] {
            self.productvideo = AttributeDescription(json: productvideo)
        }
        
        if let luminosity = json[EthosConstants.luminosity] as? [String : Any] {
            self.luminosity = AttributeDescription(json: luminosity)
        }
        
        if let jewels = json[EthosConstants.jewels] as? [String : Any] {
            self.jewels = AttributeDescription(json: jewels)
        }
    }
    
    init(name: AttributeDescription? = nil, sku: AttributeDescription? = nil, gtin: AttributeDescription? = nil, manufacturer: AttributeDescription? = nil, watchType: AttributeDescription? = nil, family: AttributeDescription? = nil, subBrand: AttributeDescription? = nil, categoryType: AttributeDescription? = nil, features: Features? = nil, createdAt: AttributeDescription? = nil, updatedAt: AttributeDescription? = nil, caseSize: AttributeDescription? = nil, casesize: AttributeDescription? = nil, caseShape: AttributeDescription? = nil, material: AttributeDescription? = nil, powerReserve: AttributeDescription? = nil, movement: AttributeDescription? = nil, straptype: AttributeDescription? = nil, interchangeableStrap: AttributeDescription? = nil, calibre: AttributeDescription? = nil, diameter: AttributeDescription? = nil, caliberBase: AttributeDescription? = nil, calibreDate: AttributeDescription? = nil, calibreChronograph: AttributeDescription? = nil, caseBack: AttributeDescription? = nil, dialcolor: AttributeDescription? = nil, hands: AttributeDescription? = nil, stockstatus: AttributeDescription? = nil, indexes: AttributeDescription? = nil, frequency: AttributeDescription? = nil, gender: AttributeDescription? = nil, ecomstock: AttributeDescription? = nil, waterResistance: AttributeDescription? = nil, glass: AttributeDescription? = nil, warrantyPeriod: AttributeDescription? = nil, limitedEdition: AttributeDescription? = nil, hidePrice: AttributeDescription? = nil, series: AttributeDescription? = nil, strapColor: AttributeDescription? = nil, bezel: AttributeDescription? = nil, preciousStone: AttributeDescription? = nil, claspType: AttributeDescription? = nil, warrantyText: AttributeDescription? = nil, customname: AttributeDescription? = nil, lugWidth: AttributeDescription? = nil, productvideo: AttributeDescription? = nil, luminosity: AttributeDescription? = nil, jewels: AttributeDescription? = nil) {
        self.name = name
        self.sku = sku
        self.gtin = gtin
        self.manufacturer = manufacturer
        self.watchType = watchType
        self.family = family
        self.subBrand = subBrand
        self.categoryType = categoryType
        self.features = features
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.caseSize = caseSize
        self.casesize = casesize
        self.caseShape = caseShape
        self.material = material
        self.powerReserve = powerReserve
        self.movement = movement
        self.straptype = straptype
        self.interchangeableStrap = interchangeableStrap
        self.calibre = calibre
        self.diameter = diameter
        self.caliberBase = caliberBase
        self.calibreDate = calibreDate
        self.calibreChronograph = calibreChronograph
        self.caseBack = caseBack
        self.dialcolor = dialcolor
        self.hands = hands
        self.stockstatus = stockstatus
        self.indexes = indexes
        self.frequency = frequency
        self.gender = gender
        self.ecomstock = ecomstock
        self.waterResistance = waterResistance
        self.glass = glass
        self.warrantyPeriod = warrantyPeriod
        self.limitedEdition = limitedEdition
        self.hidePrice = hidePrice
        self.series = series
        self.strapColor = strapColor
        self.bezel = bezel
        self.preciousStone = preciousStone
        self.claspType = claspType
        self.warrantyText = warrantyText
        self.customname = customname
        self.lugWidth = lugWidth
        self.productvideo = productvideo
        self.luminosity = luminosity
        self.jewels = jewels
    }
}
