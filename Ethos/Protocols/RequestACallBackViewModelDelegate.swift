//
//  RequestACallBackViewModelDelegate.swift
//  Ethos
//
//  Created by mac on 11/09/23.
//

import Foundation

protocol RequestACallBackViewModelDelegate {
    func requestSuccess()
    func requestFailure()
    func startIndicator()
    func stopIndicator()
}
