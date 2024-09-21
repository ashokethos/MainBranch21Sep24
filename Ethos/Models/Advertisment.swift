//
//  AdvertismentModel.swift
//  Ethos
//
//  Created by SoftGrid on 14/07/23.
//

import Foundation

class Advertisement {
    var id: Int?
    var url : String?
    var type : String?
    var location: String?
    var position: Int?
    var title: String?
    var redirect_link: String?
    
    
    init(id: Int? = nil, url: String? = nil, type: String? = nil, location: String? = nil, position: Int? = nil, title: String? = nil, redirect_link: String? = nil) {
        self.id = id
        self.url = url
        self.type = type
        self.location = location
        self.position = position
        self.title = title
        self.redirect_link = redirect_link
    }
    
    init(json : [String : Any]) {
        
        if let id = json[EthosConstants.id] as? Int {
            self.id = id
        }
        
        if let url = json[EthosConstants.url] as? String {
            self.url = url
        }
        
        if let type = json[EthosConstants.type] as? String {
            self.type = type
        }
        
        if let title = json[EthosConstants.title] as? String {
            self.title = title
        }
        
        if let redirect_link = json[EthosConstants.redirectLink] as? String {
            self.redirect_link = redirect_link
        }
        
        if let location = json[EthosConstants.location] as? String {
            self.location = location
        }
        
        if let position = json[EthosConstants.position] as? Int {
            self.position = position
        }
    }
}
