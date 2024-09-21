//
//  GetBannersViewModel.swift
//  Ethos
//
//  Created by mac on 31/08/23.
//

import Foundation

class GetBannersViewModel : NSObject {
    
    var banners = [Banner]()
    var delegate : GetBannersViewModelDelegate?
    
    func getBanners(key : BannerKeys, site : Site = Site.ethos) {
        DispatchQueue.main.async {
            self.delegate?.startIndicator()
        }
        EthosApiManager().callApi(
            endPoint: EthosApiEndPoints.getBanners,
            RequestType: .GET,
            RequestParameters: [
                EthosConstants.site : site.rawValue,
                EthosConstants.section : key.rawValue
            ],
            RequestBody: [:]) { data, response, error in
            DispatchQueue.main.async {
                self.delegate?.stopIndicator()
            }
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if let data = data {
                        DispatchQueue.main.async {
                            if let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                                let bannerModel = GetBanners(json: json)
                                self.banners = bannerModel.data?.banners ?? []
                                self.delegate?.didGetBanners(banners: self.banners)
                            }
                        }
                    }
                }
            }
        }
    }
}
