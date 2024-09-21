//
//  GetAQuoteViewModel.swift
//  Ethos
//
//  Created by mac on 11/09/23.
//

import Foundation
import UIKit
import FirebaseAnalytics
import Mixpanel

class GetAQuoteViewModel {
    
    var delegate : GetAQuoteViewModelDelegate?
    
    func callApiForRequestQuotation(site : Site = .secondMovement, forSell : Bool, requestBody : [String : String], images : [UIImage]) {
        self.delegate?.startIndicator()
        EthosApiManager().callMultiPartFormApi(endPoint: forSell ? EthosApiEndPoints.getSellQuotation : EthosApiEndPoints.getTradeQuotation, RequestParameters: [EthosConstants.site : site.rawValue], RequestBody: requestBody, images: images, imageKey: EthosConstants.imagesWithBraces) { data, response, error in
            
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200 ,
               let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
               json[EthosConstants.status] as? Bool == true  {
                self.delegate?.requestSuccess()
                let eventName = forSell ? EthosConstants.get_a_quote_sell : EthosConstants.get_a_quote_trade
                Analytics.logEvent(EthosConstants.form_submitted_ + eventName, parameters: [EthosConstants.form_name :  eventName, EthosConstants.platform : EthosConstants.IOS])
            } else {
                self.delegate?.requestFailed()
            }
        }
    }
}
