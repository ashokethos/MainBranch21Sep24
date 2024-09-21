//
//  GetCategoryViewModel.swift
//  Ethos
//
//  Created by mac on 28/07/23.
//

import Foundation
import UIKit

class GetCategoryViewModel {

    var categories = [CategoryNameId]()
    var delegate : GetCategoryViewModelDelegate?
    
    func getCategories(site : Site = .ethos) {
        EthosApiManager().callApi (
            endPoint : EthosApiEndPoints.getCategoriesList,
            RequestType : .GET,
            RequestParameters : [EthosConstants.site : site.rawValue],
            RequestBody: [:]
        ) { data, response, error in
            
            if error != nil {
                self.delegate?.didFailedToGetCategories()
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode == 200, let data = data, let datamodel = try? JSONDecoder().decode(GetCategory.self, from: data) {
                DispatchQueue.main.async {
                    self.categories = datamodel.data?.categories ?? []
                    self.delegate?.didGetCategories()
                }
            } else {
                self.delegate?.didFailedToGetCategories()
            }
        }
    }
}
