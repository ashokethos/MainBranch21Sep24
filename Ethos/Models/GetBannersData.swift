//
//  GetBannersData.swift
//  Ethos
//
//  Created by mac on 31/08/23.
//

import Foundation

class GetBannersData: NSObject {
    
    var banners: [Banner] = []
    
    init(banners : [Banner]) {
        self.banners = banners
    }
    
    init(json : [String : Any]) {
        if let bannners = json[EthosConstants.banners] as? [[String : Any]] {
            var arrBanners = [Banner]()
            for bannner in bannners {
                let bnr = Banner(json: bannner)
                arrBanners.append(bnr)
            }
            self.banners = arrBanners
        }
    }
}
