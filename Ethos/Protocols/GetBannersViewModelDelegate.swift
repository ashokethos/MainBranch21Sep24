//
//  GetBannersViewModelDelegate.swift
//  Ethos
//
//  Created by mac on 31/08/23.
//

import Foundation

protocol GetBannersViewModelDelegate {
    func didGetBanners(banners : [Banner])
    func startIndicator()
    func stopIndicator()
}
