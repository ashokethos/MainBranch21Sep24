//
//  GetArticleDetailsViewModel.swift
//  Ethos
//
//  Created by mac on 04/09/23.
//

import Foundation


class GetArticleDetailsViewModel {
    
    var articleDetails : ArticleDetails?
    var products = [Product]()
    var delegate : GetArticleDetailsViewModelDelegate?
    
    func getArticleDetails(id : Int, site : Site = Site.ethos) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.getArticleDetail + String(id), RequestType: .GET, RequestParameters: [EthosConstants.site : site.rawValue], RequestBody: [:]){ data, response, error in
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if let data = data {
                        DispatchQueue.main.async {
                            if let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                                let articleDetailsModel = GetArticleDetails(json: json)
                                self.articleDetails = articleDetailsModel.data?.article
                                self.products = articleDetailsModel.data?.products ?? []
                                if let articleDetails = self.articleDetails {
                                    self.delegate?.didGetArticledetails(articleDetails: articleDetails)
                                } else {
                                    self.delegate?.errorInGettinArticles()
                                }
                            } else {
                                self.delegate?.errorInGettinArticles()
                            }
                        }
                    } else {
                        self.delegate?.errorInGettinArticles()
                    }
                } else {
                    self.delegate?.errorInGettinArticles()
                }
            }
        }
    }
}
