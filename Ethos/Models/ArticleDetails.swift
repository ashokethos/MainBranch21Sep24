//
//  ArticleDetails.swift
//  Ethos
//
//  Created by mac on 04/09/23.
//

import Foundation

class ArticleDetails : NSObject {
    var id : Int?
    var channelID: Int?
    var title: String?
    var subtitle : String?
    var link: String?
    var articleDescription, content, pubdate, createdAt: String?
    var updatedAt: String?
    var approve: Int?
    var image: String?
    var categoryID: Int?
    var author, category: String?
    var feedURLID, commentCount: Int?
    var articleProducts: String?
    var customCategory: CustomCategory?
    var topFeaturedImage : String?
    var authorImage : String?

    
    init(id: Int? = nil, channelID: Int? = nil, title: String? = nil, subtitle: String? = nil, link: String? = nil, description: String? = nil, content: String? = nil, pubdate: String? = nil, createdAt: String? = nil, updatedAt: String? = nil, approve: Int? = nil, image: String? = nil, categoryID: Int? = nil, author: String? = nil, category: String? = nil, feedURLID: Int? = nil, commentCount: Int? = nil, articleProducts: String? = nil, customCategory: CustomCategory? = nil, topFeaturedImage : String? = nil, authorImage : String? = nil) {
        self.id = id
        self.channelID = channelID
        self.title = title
        self.link = link
        self.articleDescription = description
        self.content = content
        self.pubdate = pubdate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.approve = approve
        self.image = image
        self.categoryID = categoryID
        self.author = author
        self.category = category
        self.feedURLID = feedURLID
        self.commentCount = commentCount
        self.articleProducts = articleProducts
        self.customCategory = customCategory
        self.subtitle = subtitle
        self.topFeaturedImage = topFeaturedImage
        self.authorImage = authorImage
    }
    
    init(json : [String : Any]) {
        
        if let id = json[EthosConstants.id] as? Int {
            self.id = id
        }
        
        if let channelID = json[EthosConstants.channelID] as? Int {
            self.channelID = channelID
        }
        
        if let title = json[EthosConstants.title] as? String {
            self.title = title
        }
        
        if let subtitle = json[EthosConstants.subtitle] as? String {
            self.subtitle = subtitle
        }
        
        if let topFeaturedImage = json[EthosConstants.topFeaturedImage] as? String {
            self.topFeaturedImage = topFeaturedImage
        }
        
        if let link = json[EthosConstants.link] as? String {
            self.link = link
        }
        
        if let description = json[EthosConstants.description] as? String {
            self.articleDescription = description
        }
        
        if let content = json[EthosConstants.content] as? String {
            self.content = content
        }
        
        if let pubdate = json[EthosConstants.pubDate] as? String {
            self.pubdate = pubdate
        }
        
        if let createdAt = json[EthosConstants.createdAt] as? String {
            self.createdAt = createdAt
        }
        
        if let updatedAt = json[EthosConstants.updatedAt] as? String {
            self.updatedAt = updatedAt
        }
        
        if let approve = json[EthosConstants.approve] as? Int {
            self.approve = approve
        }
        
        if let categoryID = json[EthosConstants.categoryId] as? Int {
            self.categoryID = categoryID
        }
        
        if let author = json[EthosConstants.author] as? String {
            self.author = author
        }
        
        
        if let category = json[EthosConstants.category] as? String {
            self.category = category
        }
        
        if let feedURLID = json[EthosConstants.feedURLID] as? Int {
            self.feedURLID = feedURLID
        }
        
        if let commentCount = json[EthosConstants.commentCount] as? Int {
            self.commentCount = commentCount
        }
        
        if let articleProducts = json[EthosConstants.articleProducts] as? String {
            self.articleProducts = articleProducts
        }
        
        if let customCategory = json[EthosConstants.customeCategory] as? [String : Any] {
            self.customCategory = CustomCategory(json: customCategory)
        }
        
        if let authorImage = json[EthosConstants.authorImage] as? String {
            self.authorImage = authorImage
        }
        
        if let image = json[EthosConstants.image] as? String {
            self.image = image
        }
    }
}
