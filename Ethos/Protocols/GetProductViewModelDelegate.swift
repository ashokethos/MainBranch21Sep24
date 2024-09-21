//
//  GetProductViewModelDelegate.swift
//  Ethos
//
//  Created by mac on 23/08/23.
//

import Foundation

protocol GetProductViewModelDelegate {
    func didGetProducts(site : Site?, CategoryId : Int?)
    func errorInGettingProducts(error : String)
    func startIndicator()
    func stopIndicator()
    func startFooterIndicator()
    func stopFooterIndicator()
    func didGetProductDetails(details : Product)
    func failedToGetProductDetails()
    func didGetFilters()
    func errorInGettingFilters()
}
