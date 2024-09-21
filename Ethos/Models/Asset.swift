//
//  Asset.swift
//  Ethos
//
//  Created by SoftGrid on 14/07/23.
//

import Foundation
import UIKit

class Asset {
    var id: Int?
    var url: String?
    var type: String?
    var duration: Int?
    
    init(id: Int? = nil, url: String? = nil, type: String? = nil, duration: Int? = nil) {
        self.id = id
        self.url = url
        self.type = type
        self.duration = duration
    }
    
    init(json : [String  : Any]) {
        if let id = json[EthosConstants.id] as? Int {
            self.id = id
        }
        
        if let duration = json[EthosConstants.duration] as? Int {
            self.duration = duration
        }
        
        if let url = json[EthosConstants.url] as? String {
            self.url = url
        }
        
        if let type = json[EthosConstants.type] as? String {
            self.type = type
        }
    }
}
