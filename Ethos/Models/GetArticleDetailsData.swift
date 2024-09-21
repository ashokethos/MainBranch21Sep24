//
//  GetArticleDetailsData.swift
//  Ethos
//
//  Created by mac on 04/09/23.
//

import Foundation

class GetArticleDetailsData : NSObject {
    var article: ArticleDetails?
    var products : [Product]?
    
    init(article: ArticleDetails? = nil, products: [Product]? = nil) {
        self.article = article
        self.products = products
    }
    
    init(json : [String : Any]) {
        
        if let article = json[EthosConstants.article] as? [String : Any] {
            self.article = ArticleDetails(json: article)
        }
        
        if let products = json[EthosConstants.products] as? [[String : Any]] {
            var arrProduct = [Product]()
            for product in products {
                arrProduct.append(Product(json: product))
            }
            self.products = arrProduct
        }
    }
}
