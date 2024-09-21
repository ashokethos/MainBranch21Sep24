//
//  StoreCity.swift
//  Ethos
//
//  Created by mac on 10/08/23.
//

import Foundation

typealias StoreCities = [String: [Store]]

class StoreCity : NSObject, Codable {
    var name : String?
    var stores : [Store] = [Store]()
    
    init(name: String, stores : [Store] = [Store]()) {
        self.name = name
        self.stores = stores
    }
    
    init(json : [String : Any]) {
        self.name = json.keys.first
        
        if let stores = json.values.first as? [[String : Any]] {
            var ArrStore = [Store]()
            for store in stores {
                let storemodel = Store(json: store)
                ArrStore.append(storemodel)
            }
            
            self.stores = ArrStore
            
        }
    }
}
