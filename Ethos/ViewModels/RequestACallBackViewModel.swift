//
//  RequestACallBackViewModel.swift
//  Ethos
//
//  Created by mac on 11/09/23.
//

import Foundation
import FirebaseAnalytics

class RequestACallBackViewModel {
    
    var delegate : RequestACallBackViewModelDelegate?
    
    func callApiForRequestCallBack(params : [String :String], site : Site = .ethos) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.saveCustomerServiceEnquiryMobileApp, RequestType: .POST, RequestParameters: [EthosConstants.site : site.rawValue], RequestBody: params) { data, response, error in
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200 {
                self.delegate?.requestSuccess()
                Analytics.logEvent(EthosConstants.form_submitted_ + EthosConstants.request_call_back, parameters: [EthosConstants.form_name : EthosConstants.request_call_back, EthosConstants.platform : EthosConstants.IOS])
            } else {
                self.delegate?.requestFailure()
            }
        }
    }
    
    func callApiForSchedulePickup(params : [String :String], site : Site = .ethos) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.customerServicePickup, RequestType: .POST, RequestParameters: [EthosConstants.site : site.rawValue], RequestBody: params) { data, response, error in
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200 {
                self.delegate?.requestSuccess()
                Analytics.logEvent(EthosConstants.form_submitted_ + EthosConstants.schedule_pickup, parameters: [EthosConstants.form_name : EthosConstants.schedule_pickup, EthosConstants.platform : EthosConstants.IOS])
            } else {
                self.delegate?.requestFailure()
            }
        }
    }
    
    func callApiForRequestCallBackForStoreDetail(params : [String :String], site : Site = .ethos) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.storePageLead, RequestType: .POST, RequestParameters: [EthosConstants.site : site.rawValue], RequestBody: params) { data, response, error in
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200 {
                self.delegate?.requestSuccess()
                Analytics.logEvent(EthosConstants.form_submitted_ + EthosConstants.request_call_back_boutique, parameters: [EthosConstants.form_name : EthosConstants.request_call_back_boutique, EthosConstants.platform : EthosConstants.IOS])
            } else {
                self.delegate?.requestFailure()
            }
        }
    }
}

