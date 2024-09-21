//
//  Glossary.swift
//  Ethos
//
//  Created by SoftGrid on 21/07/23.
//

import Foundation
import UIKit
import Mixpanel

class Glossary {
    var postId : Int?
    var title : String?
    var link : String?
    var content : String?
    var isExpanded = false {
        didSet {
            if isExpanded == true {
               
            }
        }
    }
    
    init(postId: Int? = nil, title: String? = nil, link: String? = nil, content: String? = nil) {
        self.postId = postId
        self.title = title
        self.link = link
        self.content = content
    }
    
}
