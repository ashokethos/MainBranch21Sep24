//
//  SearchSuggestionModel.swift
//  Ethos
//
//  Created by Ashok kumar on 12/07/24.
//

import Foundation
import UIKit

class GetSearchSuggestionViewModel {
    
    var data : [GetSearchSuggestionModel]?
    var delegate : GetSearchSuggestionViewModelDelegate?
    
    func getSearchSuggestion (searchString : String = "", apiType: String = "", site : Site = Site.ethos) {
        
//        self.delegate?.startIndicator()
        EthosApiManager().callApi(
            endPoint: (apiType == "popularSearch") ? EthosApiEndPoints.getPopularSearch : EthosApiEndPoints.getSearchSuggestion ,
            RequestType: .GET,
            RequestParameters: [
                EthosConstants.site : site.rawValue,
                EthosConstants.searchSugg : searchString
            ],
            RequestBody: [:]
        ) { data, response, error in
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if let data = data {
                        DispatchQueue.main.async {
                            if let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                                print(json)
                                let getSearchSuggestionModel = GetSearchSuggestion(json: json)
                                self.data = getSearchSuggestionModel.data ?? []
                                self.delegate?.didGetSearchSuggestion(searchSuggestionModel: getSearchSuggestionModel, site: site, searchString: searchString)
                            }
                        }
                    }
                }
            }
        }
    }

}
