//
//  GetStoreViewModel.swift
//  Ethos
//
//  Created by mac on 10/08/23.
//

import Foundation

class GetStoreViewModel {
    
    var cities = [StoreCity]()
    
    var newStores = [Store]()
    
    var delegate : GetStoresViewModelDelegate?
    
    func getStores(
        latest : Bool = false,
        site : Site = Site.ethos
    ) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi (
            endPoint: EthosApiEndPoints.getAllStores,
            RequestType: .GET,
            RequestParameters: [
                EthosConstants.site : site.rawValue,
                EthosConstants.latest : (latest ? "1" : "0")
            ],
            RequestBody: [:]
        ) { data, response, error in
            self.delegate?.stopIndicator()
            
            if error != nil {
                self.delegate?.didFailedToGetStores()
                return
            }
            
            
            if let response = response as? HTTPURLResponse, response.statusCode == 200, let data = data, let cities = try? JSONDecoder().decode(StoreCities.self, from: data) {
                DispatchQueue.main.async {
                    var arrCity = [StoreCity]()
                    for city in cities {
                        let storeCity = StoreCity (
                            name: city.key,
                            stores: city.value
                        )
                        arrCity.append(storeCity)
                    }
                    self.cities = arrCity.sorted(by: { city1, city2 in
                        (city2.name ?? "").lowercased() > (city1.name ?? "").lowercased()
                    })
                    self.delegate?.didGetStores(
                        stores: self.cities,
                        forLatest: latest
                    )
                }
            } else {
                self.delegate?.didFailedToGetStores()
            }
        }
    }
    
    func getNewBoutiques(site : Site) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.getTopStores, RequestType: .GET, RequestParameters: [EthosConstants.site : site.rawValue], RequestBody: [:]) { data, response, error in
            self.delegate?.stopIndicator()
            
            if error != nil {
                self.delegate?.didFailedToGetNewStores()
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode == 200, let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any], let boutiques = json["boutiques"] as? [[String : Any]] {
                var arrStores = [Store]()
                for boutique in boutiques {
                    arrStores.append(Store(json: boutique))
                }
                self.newStores = arrStores
                self.delegate?.didGetNewStores(stores: self.newStores)
            } else {
                self.delegate?.didFailedToGetNewStores()
            }
        }
    }
    
    func filteredCities(filteredString : String) -> [StoreCity] {
        var filteredCities = [StoreCity]()
        for city in cities {
            var stores = [Store]()
            
            for store in city.stores {
                if (store.storeCity?.lowercased().contains(filteredString.lowercased()) ?? false) ||  (store.storeState?.lowercased().contains(filteredString.lowercased()) ?? false) {
                    stores.append(store)
                }
            }
            
            if stores.count > 0 {
                let storeCity = StoreCity(name: city.name ?? "", stores: stores)
                filteredCities.append(storeCity)
            }
        }
        return filteredCities
    }
}
