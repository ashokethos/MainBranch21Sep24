//
//  Store.swift
//  Ethos
//
//  Created by mac on 10/08/23.
//

import Foundation

class Store: NSObject, Codable {
    var storelocatorID, storeName, storeCode, storeAddress: String?
    var storePostalcode, storeCity, storeState: String?
    var storeCountry: String?
    var storePhone, storeEmail, storeFax, storeDescription: String?
    var storeMap: String?
    var storeThreesixty: String?
    var storeLatitude, storeLongitude, status, storeLink: String?
    var storeImgDesktop, storeImgMobile: String?
    var storeMarker: String?
    var storeParking: String?
    var storeBrand, storeWorkinghour, storePlaceID, storeHeadname: String?
    var storeHeadimg, storeHeadphone, storeHeadEmail, storeType: String?
    var createdTime, updateTime, storeMetaKeyword, storeMetaTitle: String?
    var storeMetaDescription: String?
    var gallery: [Gallery]?
    var imageURLPrefix: String?
    var image: String?
    var storeDisplayName : String?

    enum CodingKeys: String, CodingKey {
        case storelocatorID = "storelocator_id"
        case storeName = "store_name"
        case storeCode = "store_code"
        case storeAddress = "store_address"
        case storePostalcode = "store_postalcode"
        case storeCity = "store_city"
        case storeState = "store_state"
        case storeCountry = "store_country"
        case storePhone = "store_phone"
        case storeEmail = "store_email"
        case storeFax = "store_fax"
        case storeDescription = "store_description"
        case storeMap = "store_map"
        case storeThreesixty = "store_threesixty"
        case storeLatitude = "store_latitude"
        case storeLongitude = "store_longitude"
        case status
        case storeLink = "store_link"
        case storeImgDesktop = "store_img_desktop"
        case storeImgMobile = "store_img_mobile"
        case storeMarker = "store_marker"
        case storeParking = "store_parking"
        case storeBrand = "store_brand"
        case storeWorkinghour = "store_workinghour"
        case storePlaceID = "store_place_id"
        case storeHeadname = "store_headname"
        case storeHeadimg = "store_headimg"
        case storeHeadphone = "store_headphone"
        case storeHeadEmail = "store_head_email"
        case storeType = "store_type"
        case createdTime = "created_time"
        case updateTime = "update_time"
        case storeMetaKeyword = "store_meta_keyword"
        case storeMetaTitle = "store_meta_title"
        case storeMetaDescription = "store_meta_description"
        case gallery
        case imageURLPrefix = "image_url_prefix"
        case image
    }
    
    init(json : [String : Any]) {
        
        if let storelocatorID = json["storelocator_id"] as? String {
            self.storelocatorID = storelocatorID
        }
        
        if let storeName = json["store_name"] as? String {
            self.storeName = storeName
        }
        
        if let storeCode = json["store_code"] as? String {
            self.storeCode = storeCode
        }
        
        if let storeAddress = json["store_address"] as? String {
            self.storeAddress = storeAddress
        }
        
        if let storePostalcode = json["store_postalcode"] as? String {
            self.storePostalcode = storePostalcode
        }
        
        if let storeCity = json["store_city"] as? String {
            self.storeCity = storeCity
        }
        
        if let storeState = json["store_state"] as? String {
            self.storeState = storeState
        }
        
        if let storeCountry = json["store_country"] as? String {
            self.storeCountry = storeCountry
        }
        
        if let storePhone = json["store_phone"] as? String {
            self.storePhone = storePhone
        }
        
        if let storeEmail = json["store_email"] as? String {
            self.storeEmail = storeEmail
        }
        
        if let storeFax = json["store_fax"] as? String {
            self.storeFax = storeFax
        }
        
        if let storeDescription = json["store_description"] as? String {
            self.storeDescription = storeDescription
        }
        
        if let storeMap = json["store_state"] as? String {
            self.storeMap = storeMap
        }
        
        
        if let storeThreesixty = json["store_threesixty"] as? String {
            self.storeThreesixty = storeThreesixty
        }
        
        if let storeLatitude = json["store_latitude"] as? String {
            self.storeLatitude = storeLatitude
        }
        
        if let storeLongitude = json["store_longitude"] as? String {
            self.storeLongitude = storeLongitude
        }
        
        if let status = json["status"] as? String {
            self.status = status
        }
        
        if let storeLink = json["store_link"] as? String {
            self.storeLink = storeLink
        }
        
        if let storeImgDesktop = json["store_img_desktop"] as? String {
            self.storeImgDesktop = storeImgDesktop
        }
        
        if let storeImgMobile = json["store_img_mobile"] as? String {
            self.storeImgMobile = storeImgMobile
        }
        
        if let storeMarker = json["store_marker"] as? String {
            self.storeMarker = storeMarker
        }
        
        
        if let storeParking = json["store_parking"] as? String {
            self.storeParking = storeParking
        }
        
        if let storeBrand = json["store_brand"] as? String {
            self.storeBrand = storeBrand
        }
        
        if let storeWorkinghour = json["store_workinghour"] as? String {
            self.storeWorkinghour = storeWorkinghour
        }
        
        if let storePlaceID = json["store_place_id"] as? String {
            self.storePlaceID = storePlaceID
        }
        
        if let storeHeadname = json["store_headname"] as? String {
            self.storeHeadname = storeHeadname
        }
        
        if let storeHeadimg = json["store_headimg"] as? String {
            self.storeHeadimg = storeHeadimg
        }
        
        if let storeHeadphone = json["store_headphone"] as? String {
            self.storeHeadphone = storeHeadphone
        }
        
        if let storeHeadEmail = json["store_head_email"] as? String {
            self.storeHeadEmail = storeHeadEmail
        }
        
        if let storeType = json["store_type"] as? String {
            self.storeType = storeType
        }
        
        if let createdTime = json["created_time"] as? String {
            self.createdTime = createdTime
        }
        
        if let updateTime = json["update_time"] as? String {
            self.updateTime = updateTime
        }
        
        if let storeMetaKeyword = json["store_meta_keyword"] as? String {
            self.storeMetaKeyword = storeMetaKeyword
        }
        
        if let storeMetaTitle = json["store_meta_title"] as? String {
            self.storeMetaTitle = storeMetaTitle
        }
        
        if let storeMetaDescription = json["store_meta_description"] as? String {
            self.storeMetaDescription = storeMetaDescription
        }
        
        if let gallery = json["gallery"] as? [[String : Any]] {
            var arrGallery = [Gallery]()
            for gal in gallery {
                let data = Gallery(json: gal)
                arrGallery.append(data)
            }
            self.gallery = arrGallery
        }
        
        if let image = json["image"] as? String {
            self.image = image
        }
        
        if let imageURLPrefix = json["image_url_prefix"] as? String {
            self.imageURLPrefix = imageURLPrefix
        }
        
        if let storeDisplayName = json["store_display_name"] as? String {
            self.storeDisplayName = storeDisplayName
        }
    }
}
