//
//  LoginViewModel.swift
//  Ethos
//
//  Created by mac on 25/08/23.
//

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import Mixpanel

class AuthenticationViewModel {
    
    var delegate : AuthenticationViewModelDelegate?
    
    func loginWithSocial(
        email : String,
        firstName : String,
        lastName : String,
        method : String,
        signUp : Bool,
        site : Site = .ethos
    ) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi (
            endPoint: EthosApiEndPoints.socialLogin,
            RequestType: .POST,
            RequestParameters: [
                EthosConstants.site : site.rawValue
            ],
            RequestBody: [
                EthosConstants.email : email,
                EthosConstants.firstName : firstName,
                EthosConstants.lastName : lastName
            ]
        ) { data, response, error in
            self.delegate?.stopIndicator()
            if (error != nil) {
                self.delegate?.loginError(error: error?.localizedDescription ?? EthosConstants.error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               let data = data,
               let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                let message =  result[EthosConstants.message] as? String
                if result[EthosConstants.status] as? Int == 1 {
                    self.delegate?.loginSuccess(token: result[EthosConstants.token] as? String ?? "")
                    Userpreference.shouldSendLoginAnalytics = true
                    Userpreference.currentLoginSignupSource = method
                } else {
                    self.delegate?.loginError(error: (message ?? (result[EthosConstants.error] as? String)) ?? "")
                }
            } else {
                self.delegate?.loginError(error: EthosConstants.error)
            }
        }
    }
    
    
    func loginWithEmail(email : String, password : String) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi(
            endPoint: EthosApiEndPoints.login,
            RequestType: .POST,
            RequestParameters: [
                EthosConstants.site: Site.ethos.rawValue
            ],
            RequestBody: [
                EthosConstants.username : email,
                EthosConstants.password : password
            ]
        ) {
            data, response, error in
            self.delegate?.stopIndicator()
            
            if (error != nil) {
                self.delegate?.loginError(error: error?.localizedDescription ?? EthosConstants.error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               let data = data,
               let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                let message = result[EthosConstants.message] as? String
                if result[EthosConstants.success] as? Bool == true {
                    Userpreference.shouldSendLoginAnalytics = true
                    Userpreference.currentLoginSignupSource = EthosConstants.Email
                    self.delegate?.loginSuccess(token: result[EthosConstants.token] as? String ?? "")
                } else {
                    if message == "Please check credentials" {
                        self.delegate?.loginError(error: "Incorrect information entered. Please check your password or email again.")
                    } else {
                        self.delegate?.loginError(error: message ?? "")
                    }
                }
            } else {
                self.delegate?.loginError(error: EthosConstants.error)
            }
        }
    }
    
    
    func sendOTPToMobile(mobileNumber: String) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi(
            endPoint: EthosApiEndPoints.generateOTP + mobileNumber,
            RequestType: .GET,
            RequestParameters: [
                EthosConstants.site : Site.ethos.rawValue
            ],
            RequestBody: [:]
        ) { data, response, error in
            
            self.delegate?.stopIndicator()
            
            if (error != nil) {
                self.delegate?.otpSendFailed(error: error?.localizedDescription ?? EthosConstants.error)
                return
            }
            
            if let data = data {
                let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                let status = result?[EthosConstants.status] as? String
                let message = result?[EthosConstants.message] as? String
                let errorMessage = (result?[EthosConstants.error] as? [String : Any])?[EthosConstants.message] as? String
                let response = response as? HTTPURLResponse
                if response?.statusCode == 200,
                   status == EthosConstants.success {
                    self.delegate?.otpSendSuccess(message: message ?? EthosConstants.success)
                } else {
                    if errorMessage == "Mobile number not registered..." {
                        self.delegate?.otpSendFailed(error: "This mobile number is not registered. Sign up to create your account")
                    } else {
                        self.delegate?.otpSendFailed(error: message ?? errorMessage ?? EthosConstants.error)
                    }
                }
            }
        }
    }
    
    func verifyOTP (
        mobileNumber: String,
        otp : String
    ) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi (
            endPoint: EthosApiEndPoints.verifyOTP + mobileNumber + "/" + otp,
            RequestType: .GET,
            RequestParameters: [
                EthosConstants.site : Site.ethos.rawValue
            ],
            RequestBody: [:]
        ) { data, response, error in
            self.delegate?.stopIndicator()
            if (error != nil) {
                self.delegate?.otpVerifyFailed(error: error?.localizedDescription ?? EthosConstants.error)
                return
            }
            if let data = data {
                let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                let message = result?[EthosConstants.message] as? String
                let token = result?[EthosConstants.token] as? String
                let errorMessage = (result?[EthosConstants.error] as? [String : Any])?[EthosConstants.message] as? String
                let response = response as? HTTPURLResponse
                
                if response?.statusCode == 200, let token = token {
                    self.delegate?.otpVerifySuccess(token: token, message: message ?? EthosConstants.success.uppercased())
                    Userpreference.shouldSendLoginAnalytics = true
                    Userpreference.currentLoginSignupSource = EthosConstants.PhoneNumber
                    
                } else {
                    if errorMessage == "Wrong OTP or session expired! Please try again." {
                        self.delegate?.otpVerifyFailed(error: "Session timed-out or incorrect OTP entered.")
                    } else {
                        self.delegate?.otpVerifyFailed(error: message ?? errorMessage ?? EthosConstants.error.uppercased())
                    }
                }
            }
        }
    }
    
    func sendRegisterationOTP (
        mobileNumber : String
    ) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi (
            endPoint: EthosApiEndPoints.generateOTPRegister + mobileNumber,
            RequestType: .GET,
            RequestParameters: [
                EthosConstants.site : Site.ethos.rawValue
            ],
            RequestBody: [:]
        ) {
            data, response, error in
            self.delegate?.stopIndicator()
            if (error != nil) {
                self.delegate?.otpSendFailed(error: error?.localizedDescription ?? EthosConstants.error.uppercased())
                return
            }
            
            if let data = data {
                let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                let status = result?[EthosConstants.status] as? String
                let message = result?[EthosConstants.message] as? String
                let errorMessage = (result?[EthosConstants.error] as? [String : Any])?[EthosConstants.message] as? String
                let response = response as? HTTPURLResponse
                if response?.statusCode == 200,
                   status == EthosConstants.success {
                    self.delegate?.otpSendSuccess(message: message ?? EthosConstants.success)
                } else {
                    self.delegate?.otpSendFailed(error: message ?? errorMessage ?? EthosConstants.error.uppercased())
                }
            }
        }
    }
    
    func verifyRegisterationOTP (
        mobileNumber : String,
        otp : String
    ) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi (
            endPoint: EthosApiEndPoints.verifyOTPRegister + mobileNumber + "/" + otp,
            RequestType: .GET,
            RequestParameters: [
                EthosConstants.site : Site.ethos.rawValue
            ],
            RequestBody: [:]
        ) {
            data, response, error in
            self.delegate?.stopIndicator()
            if (error != nil) {
                self.delegate?.otpVerifyFailed(error: error?.localizedDescription ?? EthosConstants.error.uppercased())
                return
            }
            
            if let data = data {
                let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                let message = result?[EthosConstants.message] as? String
                let errorMessage = (result?[EthosConstants.error] as? [String : Any])?[EthosConstants.message] as? String
                let response = response as? HTTPURLResponse
                
                if response?.statusCode == 200 {
                    self.delegate?.otpVerifySuccess(token: "", message: message ?? EthosConstants.success.uppercased())
                } else {
                    self.delegate?.otpVerifyFailed(error: message ?? errorMessage ?? EthosConstants.error.uppercased())
                }
            }
        }
    }
    
    func registerUser (
        firstname : String,
        lastName : String,
        mobileNumber : String,
        email : String,
        password : String
    ) {
        
        let body = [
            EthosConstants.firstname: firstname,
            EthosConstants.lastname: lastName,
            EthosConstants.email: email,
            EthosConstants.password: password,
            EthosConstants.mobile: mobileNumber
        ]
        
        self.delegate?.startIndicator()
        
        EthosApiManager().callApi(
            endPoint: EthosApiEndPoints.registerUser,
            RequestType: .POST,
            RequestParameters: [
                EthosConstants.site : Site.ethos.rawValue
            ],
            RequestBody: body
        ) {
            data, response, error in
            self.delegate?.stopIndicator()
            
            if (error != nil) {
                self.delegate?.loginError(error: error?.localizedDescription ?? EthosConstants.error)
                return
            }
            
            if let data = data {
                let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                let message = result?[EthosConstants.message] as? String
                let token = result?[EthosConstants.ecomToken] as? String
                let errorMessage = (result?[EthosConstants.error] as? [String : Any])?[EthosConstants.message] as? String
                let response = response as? HTTPURLResponse
                if response?.statusCode == 200, let token = token {
                    self.delegate?.loginSuccess(token: token)
                    Userpreference.currentLoginSignupSource = EthosConstants.Email
                    Userpreference.shouldSendSignUpAnalytics = true
                } else {
                    self.delegate?.loginError(error: message ?? errorMessage ?? EthosConstants.error)
                }
            }
        }
    }
    
    func sendResetPasswordLinkOnEmail (
        email : String,
        site : Site = .ethos
    ) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi(
            endPoint: EthosApiEndPoints.sendResetLink,
            RequestType: .PUT,
            RequestParameters: [
                EthosConstants.site : site.rawValue
            ],
            RequestBody: [
                EthosConstants.email : email,
                EthosConstants.template : EthosConstants.emailReset,
                EthosConstants.webSiteId : 1
            ]
        ) {
            data, response, error in
            
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200,
               let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
               json[EthosConstants.status] as? Bool == true {
                self.delegate?.resetPasswordLinkSendSuccess()
            } else {
                if let data = data,
                   let errorjson = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                   let error = errorjson[EthosConstants.error] as? [String : Any],
                   let message = error[EthosConstants.message] as? String {
                    if message == EthosConstants.emailNotRegisteredMessage {
                        self.delegate?.resetPasswordLinkSendFailed(error: EthosConstants.emailNotRegistered)
                    } else {
                        self.delegate?.resetPasswordLinkSendFailed(error: message)
                    }
                } else {
                    self.delegate?.resetPasswordLinkSendFailed(error: EthosConstants.requestFailed)
                }
            }
        }
    }
    
    func changePasswordForLoggedInUser(
        currentPassword : String,
        newPassword : String,
        site : Site = .ethos,
        token : String
    ) {
        let param = [
            EthosConstants.currentPassword : currentPassword,
            EthosConstants.newPassword : newPassword
        ]
        
        self.delegate?.startIndicator()
        
        EthosApiManager().callApi(
            endPoint: EthosApiEndPoints.changePassword,
            RequestType: .PUT,
            RequestParameters: [
                EthosConstants._token : token,
                EthosConstants.site : site.rawValue
            ],
            RequestBody: param
        ) { data, response, error in
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                        if json[EthosConstants.status] as? Int == 1 {
                            self.delegate?.passwordChangeSuccess(message: EthosConstants.passWordChangedSuccesfully)
                        }
                    }
                } else if response.statusCode == 401 {
                    self.delegate?.passwordChangeFailed(error: EthosConstants.currentPasswordIsWrong)
                } else if response.statusCode == 400 {
                    self.delegate?.passwordChangeFailed(error: EthosConstants.strongPassworgMessage)
                } else {
                    self.delegate?.passwordChangeFailed(error: EthosConstants.passwordChangeError)
                }
            }
        }
    }
    
    func signInWithGoogle(
        controller : UIViewController,
        signUp : Bool
    ) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        self.delegate?.startIndicator()
        GIDSignIn.sharedInstance.signIn(withPresenting: controller) {
            result, error in
            self.delegate?.stopIndicator()
            
            guard error == nil else { return }
            
            guard let user = result?.user,
                  let givenName = user.profile?.givenName,
                  let lastname = user.profile?.familyName else { return }
            
            if let email = user.profile?.email {
                self.loginWithSocial(email: email, firstName: givenName, lastName: lastname, method: "Google", signUp: signUp)
            }
        }
    }
}
