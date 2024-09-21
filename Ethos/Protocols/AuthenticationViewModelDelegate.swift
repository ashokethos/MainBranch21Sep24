//
//  LoginViewModelDelegate.swift
//  Ethos
//
//  Created by mac on 25/08/23.
//

import Foundation

protocol AuthenticationViewModelDelegate {
    func loginSuccess(token : String)
    func loginError(error : String)
    func otpSendSuccess(message : String)
    func otpSendFailed(error : String)
    func otpVerifySuccess(token : String, message : String)
    func otpVerifyFailed(error : String)
    func resetPasswordLinkSendSuccess()
    func resetPasswordLinkSendFailed(error : String)
    
    func startIndicator()
    func stopIndicator()
    
    func passwordChangeSuccess(message : String)
    func passwordChangeFailed(error : String)
    
}
