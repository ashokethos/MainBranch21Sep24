//
//  ArticleModel.swift
//  Ethos
//
//  Created by SoftGrid on 14/07/23.
//

import Foundation
import UIKit

class Article {
    var id: Int?
    var title, author: String?
    var video: String?
    var category, mainCategories, topFeaturedImage: String?
    var createdDate, commentCount: Int?
    var assets: [Asset]?
    var forPreOwn = false

    init(id: Int? = nil, title: String? = nil, author: String? = nil, video: String? = nil, category: String? = nil, mainCategories: String? = nil, createdDate: Int? = nil, topFeaturedImage: String? = nil, commentCount: Int? = nil, assets: [Asset]? = nil) {
        self.id = id
        self.title = title
        self.author = author
        self.video = video
        self.category = category
        self.mainCategories = mainCategories
        self.createdDate = createdDate
        self.commentCount = commentCount
        self.assets = assets
        self.topFeaturedImage = topFeaturedImage
    }
    
    init(json : [String : Any]) {
        
        if let id = json[EthosConstants.id] as? Int {
            self.id = id
        }
        
        if let title = json[EthosConstants.title] as? String {
            self.title = title
        }
        
        if let author = json[EthosConstants.author] as? String {
            self.author = author
        }
        
        if let video = json[EthosConstants.video] as? String {
            self.video = video
        }
        
        if let category = json[EthosConstants.category] as? String {
            self.category = category
        }
        
        if let topFeaturedImage = json[EthosConstants.topFeaturedImage] as? String {
            self.topFeaturedImage = topFeaturedImage
        }
        
        if let mainCategories = json[EthosConstants.mainCategories] as? String {
            self.mainCategories = mainCategories
        }
        
        if let createdDate = json[EthosConstants.createdDate] as? Int {
            self.createdDate = createdDate
        }
        
        if let commentCount = json[EthosConstants.commentCount] as? Int {
            self.commentCount = commentCount
        }
        
        if let assets = json[EthosConstants.assets] as? [[String : Any]] {
            var arrAssets = [Asset]()
            
            for asset in assets {
                arrAssets.append(Asset(json: asset))
            }
            
            self.assets = arrAssets
        }
    }
    
}
