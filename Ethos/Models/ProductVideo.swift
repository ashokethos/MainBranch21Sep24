//
//  ProductVideo.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class ProductVideo : NSObject {
    
    var title : String?
    var url : String?
    
    init(title: String? = nil, url: String? = nil) {
        self.title = title
        self.url = url
    }
    
    init(json : [String : Any]) {
        if let title = json[EthosConstants.title] as? String {
            self.title = title
        }
        
        if let url = json[EthosConstants.url] as? String {
            self.url = url
        }
    }
    
}
