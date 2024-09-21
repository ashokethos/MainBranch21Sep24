//
//  TitleDescriptionImageModel.swift
//  Ethos
//
//  Created by mac on 17/08/23.
//

import Foundation

struct TitleDescriptionImageModel {
    var title : String
    var description : String
    var image : String
    var btnTitle : String
    
    init(title: String, description: String, image: String, btnTitle: String = ""){
        self.title = title
        self.description = description
        self.image = image
        self.btnTitle = btnTitle
    }
    
}
