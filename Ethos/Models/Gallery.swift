//
//  Gallery.swift
//  Ethos
//
//  Created by mac on 10/08/23.
//

import Foundation

struct Gallery: Codable {
    
    var galleryImg, status: String?

    enum CodingKeys: String, CodingKey {
        case galleryImg = "gallery_img"
        case status
    }
    
    init(json : [String : Any]) {
        if let galleryImg = json[EthosConstants.galleryImg] as? String {
            self.galleryImg = galleryImg
        }
        
        if let status = json[EthosConstants.status] as? String {
            self.status = status
        }
    }
}
