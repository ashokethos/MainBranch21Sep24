//
//  GetArticleCategoriesViewModel.swift
//  Ethos
//
//  Created by mac on 31/08/23.
//

import Foundation

class GetArticleCategoriesViewModel : NSObject {
    
    var articleCategories = [ArticlesCategory]()
    
    var delegate : GetArticleCategoriesViewModelDelegate?
    
    func getArticleCategories(site : Site = Site.ethos) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.getArticleCategories, RequestType: .GET, RequestParameters: [EthosConstants.site : site.rawValue, EthosConstants.readlist : "1"], RequestBody: [:]){ data, response, error in
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if let data = data {
                        DispatchQueue.main.async {
                            if let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                                let articleCategoriesModel = GetArticleCategories(json: json)
                                self.articleCategories = articleCategoriesModel.data?.categories ?? []
                                self.delegate?.didGetArticleCategories(
                                    articleCategories: articleCategoriesModel.data?.categories ?? []
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
