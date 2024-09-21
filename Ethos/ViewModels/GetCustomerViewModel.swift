//
//  GetCustomerViewModel.swift
//  Ethos
//
//  Created by mac on 26/08/23.
//

import Foundation
import UIKit


class GetCustomerViewModel {
    
    var delegate : GetCustomerViewModelDelegate?
    var delegatePurchaseHistory : GetPurchaseHistoryViewModelDelegate?
    var purchaseHistoryData = [GetPurchaseHistoryData]()
    var customer : Customer?
    
    func getCustomerDetails(site : Site = .ethos) {
        if let token = Userpreference.token {
            self.delegate?.startProfileIndicator()
            EthosApiManager().callApi (
                endPoint: EthosApiEndPoints.getCustomerDetails,
                RequestType: .GET,
                RequestParameters: [
                    EthosConstants._token: token,
                    EthosConstants.site : site.rawValue
                ],
                RequestBody: [:]
            ) { data, response, error in
                self.delegate?.stopProfileIndicator()
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let data = data {
                            DispatchQueue.main.async {
                                if let customer = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                                    self.customer = Customer(json: customer)
                                    if let customer = self.customer {
                                        self.delegate?.didGetCustomerData(data: customer)
                                        
                                        var mobileNumber : String?
                                        
                                        for attribute in customer.customAttributes ?? [] {
                                            if attribute.attributeCode == EthosConstants.mobile {
                                                mobileNumber = attribute.value
                                            }
                                        }
                                        
                                        Userpreference.setUserData(firstName: customer.firstname, lastName: customer.lastname, email: customer.email ,phoneNumber: mobileNumber, location: customer.extraAttributes?.location, userID: customer.id, gender: customer.gender)
                                    }
                                }
                            }
                        }
                    } else if response.statusCode == 401 {
                        if let data = data {
                            if let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                                if let error = json[EthosConstants.error] as? [String : Any],
                                   let message = error[EthosConstants.message] as? String {
                                    self.delegate?.unAuthorizedToken(message: message)
                                }
                            }
                        } else {
                            self.delegate?.unAuthorizedToken(message: EthosConstants.userNotAuthorized)
                        }
                    }
                }
            }
        }
    }
    
    
    func updateProfile (
        site : Site = .ethos,
        params : [String: Any]
    ) {
        guard let token = Userpreference.token else { return }
        self.delegate?.startProfileIndicator()
        EthosApiManager().callApi(
            endPoint: EthosApiEndPoints.getCustomerDetails,
            RequestType: .PUT,
            RequestParameters: [
                EthosConstants._token : token,
                EthosConstants.site : site.rawValue
            ],
            RequestBody: params
        ) {
            data, response, error in
            self.delegate?.stopProfileIndicator()
            if let response = response as? HTTPURLResponse,
               let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                print(json)
                if response.statusCode == 200 {
                    self.delegate?.updateProfileSuccess(message: EthosConstants.profileUpdatedSuccesfully)
                    let customer = Customer(json: json)
                    var mobileNumber : String?
                    for attribute in customer.customAttributes ?? [] {
                        if attribute.attributeCode == "mobile" {
                            mobileNumber = attribute.value
                        }
                    }
                    Userpreference.setUserData(firstName: customer.firstname, lastName: customer.lastname, email: customer.email ,phoneNumber: mobileNumber, location: customer.extraAttributes?.location, userID: customer.id, gender: customer.gender)
                } else if response.statusCode == 401 {
                    self.delegate?.updateProfileFailed(message: EthosConstants.userNotAuthorized)
                } else if response.statusCode == 400 {
                    self.delegate?.updateProfileFailed(message: "")
                } else {
                    self.delegate?.updateProfileFailed(message: "")
                }
            }
        }
    }
    
    
    func getCustomersPointBalance(site : Site = .ethos) {
        if let customer = self.customer,
           Userpreference.token != nil,
           customer.customAttributes?.contains(where: { attr in
               attr.attributeCode == EthosConstants.mobile
           }) ?? false {
            
            var mobile : String?
            
            for attr in customer.customAttributes ?? [] {
                if attr.attributeCode == EthosConstants.mobile {
                    mobile = attr.value
                }
            }
            
            guard let mobile = mobile,
                  mobile != "" else { return }
            
            EthosApiManager().callApi (
                endPoint: EthosApiEndPoints.getCustomerPointBalance + mobile,
                RequestType: .GET,
                RequestParameters: [
                    EthosConstants.site : site.rawValue
                ],
                RequestBody: [:]
            ) { data, response, error in
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                    if json[EthosConstants.status] as? Int == 1 {
                        if let data = json[EthosConstants.data] as? [String : Any] {
                            if let pointBalance = data[EthosConstants.pointsBalance] as? Int {
                                self.delegate?.didGetCustomerPoints(points: pointBalance)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getPurchaseHistory (site : Site = .ethos) {
        
        if let customer = self.customer, Userpreference.token != nil, customer.customAttributes?.contains(where: { attr in
               attr.attributeCode == EthosConstants.mobile
           }) ?? false {
            
            var mobile : String?
            let customer = self.customer
            for attr in customer?.customAttributes ?? [] {
                if attr.attributeCode == EthosConstants.mobile {
                    mobile = attr.value
                }
            }
            
            guard let mobile = mobile,
                  mobile != "" else { return }
            
            self.delegatePurchaseHistory?.startIndicator()
            
            let body = [String: Any]()
            let requestType = RequestType.GET
            let params : [String : String] = [
                EthosConstants.site : site.rawValue,
                //            EthosConstants.limit : String(self.limit),
            ]
            
            EthosApiManager().callApi (endPoint : EthosApiEndPoints.getCustomerPurchaseHistory + mobile, RequestType : requestType, RequestParameters : params, RequestBody : body) { data, response, error in
                if let response = response as? HTTPURLResponse {
                    self.delegatePurchaseHistory?.stopIndicator()
                    if response.statusCode == 200 {
                        if let data = data,
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                            let purchaseHistory = GetPurchaseHistory(json: json)
                            self.purchaseHistoryData = purchaseHistory?.data ?? []
                            self.delegatePurchaseHistory?.didGetPurchaseHistory(purchaseHistoryData:  self.purchaseHistoryData)
                        }
                    } else {
                        self.delegatePurchaseHistory?.errorInGettingPurchaseHistory(error: "error")
                    }
                }
            }
        }
    }
    
    func deleteAccount(site : Site = .ethos) {
        if let token = Userpreference.token,
           let id = self.customer?.id {
            self.delegate?.startProfileIndicator()
            EthosApiManager().callApi(
                endPoint: EthosApiEndPoints.customers + String(id),
                RequestType: .DELETE,
                RequestParameters: [
                    EthosConstants.site : site.rawValue,
                    EthosConstants._token : token
                ],
                RequestBody: [:]
            ) { data, response, error in
                self.delegate?.stopProfileIndicator()
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        self.delegate?.userDeleteSuccess()
                    } else {
                        self.delegate?.userDeleteFailed(error: EthosConstants.requestFailed)
                    }
                }
            }
        }
    }
    
    
    func updateProfileImage(
        images : [UIImage],
        completion : @escaping(UIImage) -> ()
    ) {
        if images.count != 0,
           let token = Userpreference.token {
            self.delegate?.startProfileIndicator()
            EthosApiManager().callMultiPartFormApi(
                endPoint: EthosApiEndPoints.updateCustomerProfileImage,
                RequestParameters: [
                    EthosConstants.site : Site.ethos.rawValue,
                    EthosConstants._token : token
                ],
                RequestBody: [
                    EthosConstants.customerId : String(self.customer?.id ?? 0)
                ],
                images: images,
                imageKey: EthosConstants.image
            ) { data, response, error in
                self.delegate?.stopProfileIndicator()
                if let response = response as? HTTPURLResponse {
                    print(response)
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                        if json[EthosConstants.status] as? Int == 1 {
                            if let image = json[EthosConstants.image] as? String {
                                UIImage.loadFromURL(url: image) { image in
                                    self.delegate?.stopProfileIndicator()
                                    completion(image)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
