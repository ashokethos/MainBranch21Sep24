//
//  CheckOurSellingPriceViewModel.swift
//  Ethos
//
//  Created by mac on 21/09/23.
//

import Foundation
import UIKit
import Mixpanel


class CheckOurSellingPriceViewModel {
    
    var delegate : CheckOurSellingPriceViewModelDelegate?
    
    func callApiForCheckOurSellingPrice(product : Product,params : [String :String], site : Site = .ethos) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.checkOurSellingPrice, RequestType: .POST, RequestParameters: [EthosConstants.site : site.rawValue], RequestBody: params) { data, response, error in
            self.delegate?.stopIndicator()
            
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                print(json )
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200 {
                
                
                Mixpanel.mainInstance().trackWithLogs(
                    event: EthosConstants.CheckProductSellingPriceSubmitted,
                    properties: [
                        EthosConstants.Email : Userpreference.email,
                        EthosConstants.UID : Userpreference.userID,
                        EthosConstants.Gender : Userpreference.gender,
                        EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                        EthosConstants.Platform : EthosConstants.IOS,
                        EthosConstants.ProductType : product.extensionAttributes?.ethProdCustomeData?.brand,
                        EthosConstants.ProductName : product.extensionAttributes?.ethProdCustomeData?.productName,
                        EthosConstants.SKU :  product.sku,
                        EthosConstants.Price : product.price,
                        EthosConstants.FullName : params[EthosConstants.Name],
                        EthosConstants.EmailAddress : params[EthosConstants.Email],
                        EthosConstants.PhoneNumber : params[EthosConstants.Phone],
                        EthosConstants.City : params[EthosConstants.city]
                        
                    ])
                
                self.delegate?.requestSuccess(message: EthosConstants.requestSuccess)
            } else {
                self.delegate?.requestFailure(error: EthosConstants.requestFailed)
            }
        }
    }
}

protocol CheckOurSellingPriceViewModelDelegate {
    func requestSuccess(message : String)
    func requestFailure(error : String)
    func startIndicator()
    func stopIndicator()
}
