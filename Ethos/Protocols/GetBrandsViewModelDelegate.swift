//
//  GetBrandsViewModelDelegate.swift
//  Ethos
//
//  Created by mac on 29/08/23.
//

import Foundation

protocol GetBrandsViewModelDelegate {
    func didGetBrands(brands : [BrandModel])
    func didGetBrandsForSellOrTrade(brands : [BrandForSellOrTrade])
    func didGetFormBrands(brands : [FormBrand])
    func errorInGettingBrands()
    func startIndicator()
    func stopIndicator()
}
