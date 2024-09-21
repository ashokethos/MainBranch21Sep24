//
//  HelpCenterMainCategories.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class HelpCenterMainCategories : NSObject {
    var title : String
    var subtitle : String
    var image : String
    var categoryId : Int?
    
    init(title: String, subtitle: String, image: String, categoryId : Int? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.categoryId = categoryId
    }
}
