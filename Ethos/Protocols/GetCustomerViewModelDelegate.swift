//
//  GetCustomerViewModelDelegate.swift
//  Ethos
//
//  Created by mac on 26/08/23.
//

import Foundation

protocol GetCustomerViewModelDelegate {
    func didGetCustomerData(data : Customer)
    func unAuthorizedToken(message : String)
    func startProfileIndicator()
    func stopProfileIndicator()
    func updateProfileSuccess(message: String)
    func updateProfileFailed(message : String)
    func didGetCustomerPoints(points : Int)
    func userDeleteSuccess()
    func userDeleteFailed(error : String)
}
