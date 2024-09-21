//
//  GetBrandsViewModel.swift
//  Ethos
//
//  Created by mac on 29/08/23.
//

import Foundation

class GetBrandsViewModel {
    
    var brands = [BrandModel]()
    var brandsForSellOrTrade = [BrandForSellOrTrade]()
    var formBrands = [FormBrand]()
    var delegate : GetBrandsViewModelDelegate?
    
    func getBrands(site : Site = Site.ethos, sorted : Bool = false, isAscending : Bool = true, includeRolex : Bool) {
        var params = [EthosConstants.site : site.rawValue]
        if sorted == true {
            params[EthosConstants.sorted] = isAscending ? EthosConstants.asc : EthosConstants.desc
        }
        self.delegate?.startIndicator()
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.getBrands, RequestType: .GET, RequestParameters: params, RequestBody: [:]){ data, response, error in
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if let data = data {
                        DispatchQueue.main.async {
                            if let brandsModel = try? JSONDecoder().decode(GetBrands.self, from: data) {
                                if site == .ethos, let url = Bundle.main.url(forResource: "Rolex", withExtension: "png"), includeRolex == true  {
                                    let rolexBrand = BrandModel(
                                        name: "Rolex",
                                        image: url.absoluteString
                                    )
                                    self.brands = [rolexBrand] +  (brandsModel.data?.brands ?? [])
                                    self.delegate?.didGetBrands(brands: self.brands)
                                } else {
                                    self.brands = brandsModel.data?.brands ?? []
                                    self.delegate?.didGetBrands(brands: self.brands)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getBrandsForSellOrTrade(site : Site = Site.ethos) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.getBrandsForSellOrTrade, RequestType: .GET, RequestParameters: [EthosConstants.site : site.rawValue], RequestBody: [:]){ data, response, error in
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if let data = data {
                        DispatchQueue.main.async {
                            if let brandsModel = try? JSONDecoder().decode(GetBrandsForSellOrTrade.self, from: data) {
                                let brands = brandsModel.data?.brands?.sorted(by: { b1, b2 in
                                    (b2.label ?? "").lowercased() > (b1.label ?? "").lowercased()
                                }) ?? []
                                self.brandsForSellOrTrade = brands.filter({ brand in
                                    brand.label?.trimmingCharacters(in: .whitespaces) != ""
                                }).sorted(by: { brand1, brand2 in
                                    brand1.label?.lowercased() ?? "" == "rolex"
                                })
                                
                                self.delegate?.didGetBrandsForSellOrTrade(brands: self.brandsForSellOrTrade)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getBrandsForFormData(site : Site = Site.ethos) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.formBrands, RequestType: .GET, RequestParameters: [EthosConstants.site : site.rawValue], RequestBody: [:]){ data, response, error in
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if let data = data {
                        DispatchQueue.main.async {
                            if let json = try? JSONSerialization.jsonObject(with: data) as? [String  : Any] {
                                let formBrandData = FormBrandsData(json: json)
                                self.formBrands = formBrandData.brands.sorted(by: { brand1, brand2 in
                                    brand1.label?.lowercased() ?? "" == "rolex"
                                })
                                self.delegate?.didGetFormBrands(brands: self.formBrands)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getSchedulePickupBrands(site : Site) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.schedulePickupBrands, RequestType: .GET, RequestParameters: [EthosConstants.site : site.rawValue], RequestBody: [:]){ data, response, error in
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if let data = data {
                        DispatchQueue.main.async {
                            if let json = try? JSONSerialization.jsonObject(with: data) as? [String  : Any] {
                                let formBrandData = FormBrandsData(json: json)
                                self.formBrands = formBrandData.brands.sorted(by: { brand1, brand2 in
                                    brand1.label?.lowercased() ?? "" == "rolex"
                                })
                                self.delegate?.didGetFormBrands(brands: self.formBrands)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getRequestACallBackBrands(site : Site) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.requestACallBackBrands, RequestType: .GET, RequestParameters: [EthosConstants.site : site.rawValue], RequestBody: [:]){ data, response, error in
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if let data = data {
                        DispatchQueue.main.async {
                            if let json = try? JSONSerialization.jsonObject(with: data) as? [String  : Any] {
                                let formBrandData = FormBrandsData(json: json)
                                self.formBrands = formBrandData.brands.sorted(by: { brand1, brand2 in
                                    brand1.label?.lowercased() ?? "" == "rolex"
                                })
                                self.delegate?.didGetFormBrands(brands: self.formBrands)
                            }
                        }
                    }
                }
            }
        }
    }
}
