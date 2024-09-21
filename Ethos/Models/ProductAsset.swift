//
//  ProductAsset.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class ProductAsset : NSObject {
    var id: Int?
    var mediaType: String?
    var position: Int?
    var disabled: Bool?
    var types: [String]?
    var file: String?
    
    init(json : [String : Any]) {
        if let id = json[EthosConstants.id] as? Int {
            self.id = id
        }
        
        if let mediaType = json[EthosConstants.mediaType] as? String {
            self.mediaType = mediaType
        }
        
        if let position = json[EthosConstants.position] as? Int {
            self.position = position
        }
        
        if let disabled = json[EthosConstants.disabled] as? Bool {
            self.disabled = disabled
        }
        
        if let types = json[EthosConstants.types] as? [String] {
            self.types = types
        }
        
        if let file = json[EthosConstants.file] as? String {
            self.file = file
        }
    }
    
    init(id: Int?, mediaType: String?, position: Int?, disabled: Bool?, types: [String]?, file: String?) {
        self.id = id
        self.mediaType = mediaType
        self.position = position
        self.disabled = disabled
        self.types = types
        self.file = file
    }
}
