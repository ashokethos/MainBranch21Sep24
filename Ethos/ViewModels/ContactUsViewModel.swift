//
//  ContactUsViewModel.swift
//  Ethos
//
//  Created by mac on 20/09/23.
//

import Foundation
import FirebaseAnalytics
import Mixpanel

class ContactUsViewModel {
    
    var delegate : ContactUsViewModelDelegate?
    
    var contacts : [String : Any] = [:]
    
    func callApiForContactUs(params : [String :String], site : Site = .ethos) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.contactus, RequestType: .POST, RequestParameters: [EthosConstants.site : site.rawValue], RequestBody: params) { data, response, error in
            self.delegate?.stopIndicator()
            
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                print(json )
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200 {
                
                Analytics.logEvent(EthosConstants.form_submitted_ + EthosConstants.contact_us, parameters: [EthosConstants.form_name : EthosConstants.contact_us, EthosConstants.platform : EthosConstants.IOS])
                
                let properties : Properties = [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.Name : params[EthosConstants.name],
                    EthosConstants.FormEmail : params[EthosConstants.email],
                    EthosConstants.FormNumber : params[EthosConstants.phone],
                    EthosConstants.Subject : params[EthosConstants.subject],
                    EthosConstants.City : params[EthosConstants.city],
                    EthosConstants.Message : params[EthosConstants.message]
                ]
                
                print(properties)
                
                Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.ContactUsFormFilled, properties: properties
                )
                
                self.delegate?.requestSuccess(message: EthosConstants.requestSuccess)
            } else {
                self.delegate?.requestFailure(error: EthosConstants.requestFailed)
            }
        }
    }
    
    func getContacts(site : Site = .ethos, completion : @escaping([String : Any]) -> ()) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.helpSupport, RequestType: .GET, RequestParameters: [EthosConstants.site: site.rawValue], RequestBody: [:]) { data, response, error in
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200, let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any]  {
                self.contacts = json
                self.delegate?.didGetContacts(json: json, site: site)
                completion(json)
            } else {
                self.delegate?.didGetContacts(json: [:], site: site)
                completion([:])
            }
        }
    }
}

protocol ContactUsViewModelDelegate {
    func requestSuccess(message : String)
    func requestFailure(error : String)
    func startIndicator()
    func stopIndicator()
    func didGetContacts(json : [String : Any], site : Site)
}
