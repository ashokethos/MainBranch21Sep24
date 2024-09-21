//
//  GetArticlesData.swift
//  Ethos
//
//  Created by SoftGrid on 14/07/23.
//

import Foundation
import UIKit

class GetArticlesData  {
    var articles: [Article]?
    var advertisements: [Advertisement]?
    var totalCount, currentDataCount, currentOffset, adRepeatAfter : Int?
    
    init(articles: [Article], advertisements: [Advertisement], totalCount: Int, currentDataCount: Int, currentOffset: Int, adRepeatAfter: Int) {
        self.articles = articles
        self.advertisements = advertisements
        self.totalCount = totalCount
        self.currentDataCount = currentDataCount
        self.currentOffset = currentOffset
        self.adRepeatAfter = adRepeatAfter
    }
    
    init(json : [String : Any]) {
        
        if let totalCount = json[EthosConstants.totalCount] as? Int {
            self.totalCount = totalCount
        }
        
        if let currentDataCount = json[EthosConstants.currentDataCount] as? Int {
            self.currentDataCount = currentDataCount
        }
        
        if let currentOffset = json[EthosConstants.currentOffset] as? Int {
            self.currentOffset = currentOffset
        }
        
        if let adRepeatAfter = json[EthosConstants.adRepeatAfter] as? Int {
            self.adRepeatAfter = adRepeatAfter
        }
        
        if let articles = json[EthosConstants.articles]  as? [[String : Any]]{
            var arrArticle = [Article]()
            for article in articles {
                arrArticle.append(Article(json: article))
            }
            self.articles = arrArticle
        }
        
        if let advertisements = json[EthosConstants.advertisements]  as? [[String : Any]]{
            var arrAdvertisement = [Advertisement]()
            for ad in advertisements {
                arrAdvertisement.append(Advertisement(json: ad))
            }
            self.advertisements = arrAdvertisement
        }
    }
}
