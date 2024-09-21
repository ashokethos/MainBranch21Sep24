//
//  GetAQuoteViewModelDelegate.swift
//  Ethos
//
//  Created by mac on 11/09/23.
//

import Foundation

protocol GetAQuoteViewModelDelegate {
    func requestSuccess()
    func requestFailed()
    func startIndicator()
    func stopIndicator()
}
