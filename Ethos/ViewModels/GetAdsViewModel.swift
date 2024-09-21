//
//  GetAdsViewModel.swift
//  Ethos
//
//  Created by mac on 27/09/23.
//

import Foundation


class GetAdsViewModel : NSObject {
    
    var ads = [Advertisement]()
    
    func getAdvertisment(site : Site = .ethos, location : String? = nil,  completion : @escaping () -> ()) {
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.getAds, RequestType: .GET, RequestParameters: [EthosConstants.site : site.rawValue], RequestBody: [:]) { data, response, error in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 , let data  = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any], json[EthosConstants.status] as? Bool == true {
                let data  = json[EthosConstants.data] as? [String : Any]
                let ads = data?[EthosConstants.ads] as? [[String : Any]]
                var advertisments = [Advertisement]()
                for ad in ads ?? [] {
                    let advertisment = Advertisement(json: ad)
                    if let location = location {
                        if advertisment.location == location {
                            advertisments.append(advertisment)
                        }
                    } else {
                        advertisments.append(advertisment)
                    }
                }
                
                self.ads = advertisments
                completion()
                
            } else {
                completion()
            }
        }
    }
}
