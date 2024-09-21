//
//  GetStoresViewModelDelegate.swift
//  Ethos
//
//  Created by mac on 10/08/23.
//

import Foundation

protocol GetStoresViewModelDelegate {
    func didGetStores(stores : [StoreCity], forLatest : Bool)
    func didGetNewStores(stores : [Store])
    func didFailedToGetStores()
    func didFailedToGetNewStores()
    func startIndicator()
    func stopIndicator()
}
