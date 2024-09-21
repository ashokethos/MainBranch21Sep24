//
//  GetArticleCategoriesData.swift
//  Ethos
//
//  Created by mac on 31/08/23.
//

import Foundation

class GetArticleCategoriesData : NSObject {
    
    var categories: [ArticlesCategory]?
    
    init(categories: [ArticlesCategory]? = nil) {
        self.categories = categories
    }
    
    init(json : [String : Any]) {
        if let categories = json[EthosConstants.categories] as? [[String : Any]] {
            var arrcategory = [ArticlesCategory]()
            for category in categories {
                arrcategory.append(ArticlesCategory(json: category))
            }
            self.categories = arrcategory
        }
    }
}
