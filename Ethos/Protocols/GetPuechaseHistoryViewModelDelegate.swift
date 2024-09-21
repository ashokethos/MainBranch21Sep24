//
//  GetPuechaseHistoryViewModelDelegate.swift
//  Ethos
//
//  Created by Ashok kumar on 15/07/24.
//

import Foundation


protocol GetPurchaseHistoryViewModelDelegate {
    func didGetPurchaseHistory(purchaseHistoryData: [GetPurchaseHistoryData])
    func errorInGettingPurchaseHistory(error : String)
    func startIndicator()
    func stopIndicator()
    func startFooterIndicator()
    func stopFooterIndicator()
}
