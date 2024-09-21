//
//  GetBanners.swift
//  Ethos
//
//  Created by mac on 31/08/23.
//

import Foundation

class GetBanners: NSObject {
    
    var status: Bool?
    var data: GetBannersData?
    
    init(status: Bool? = nil, data: GetBannersData? = nil) {
        self.status = status
        self.data = data
    }
    
    init(json : [String : Any]) {
        if let status = json[EthosConstants.status] as? Bool {
            self.status = status
        }
        
        if let data = json[EthosConstants.data] as? [String : Any] {
            self.data = GetBannersData(json: data)
        }
    }
}
