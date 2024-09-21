//
//  LatestViewModel.swift
//  Ethos
//
//  Created by SoftGrid on 14/07/23.
//

import Foundation

class GetArticlesViewModel {
    
    var articles = [Article]()
    var advertisements = [Advertisement]()
    var delegate : GetArticlesViewModelDelegate?
    var gettingNewArticles = false
    var limit = 10
    var adRepeatAfter = 3
    var totalCount = 0
    var currentDataCount: Int?
    var currentOffset = 0
    let defaultOffset = 0
    
    func getArticles (
        category : String = "",
        site : Site = Site.ethos,
        searchString : String = "",
        featuredVideo : Bool = false,
        watchGuide : Bool = false,
        forViewAll : Bool = false
    ) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi(
            endPoint: forViewAll ? EthosApiEndPoints.getViewAllArticles : EthosApiEndPoints.getArticles,
            RequestType: .GET,
            RequestParameters: [
                EthosConstants.offset: String(self.defaultOffset),
                EthosConstants.limit : String(limit),
                EthosConstants.category : category,
                EthosConstants.site : site.rawValue,
                EthosConstants.featuredVideo : featuredVideo ? "1" : "0",
                EthosConstants.watchGuide : watchGuide ? "1" : "0",
                EthosConstants.searchStr : searchString
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
                                let getArticleModel = GetArticles(json: json)
                                self.articles = getArticleModel.data?.articles ?? []
                                self.advertisements = getArticleModel.data?.advertisements ?? []
                                self.currentOffset = getArticleModel.data?.currentOffset ?? 0
                                self.adRepeatAfter = getArticleModel.data?.adRepeatAfter ?? 0
                                self.currentDataCount = getArticleModel.data?.currentDataCount ?? 0
                                self.totalCount = getArticleModel.data?.totalCount ?? 0
                                
                                self.delegate?.didGetArticles(
                                    category: category,
                                    offset: self.currentOffset,
                                    limit: self.limit,
                                    articleModel: getArticleModel,
                                    site: site,
                                    searchString: searchString,
                                    featuredVideo: featuredVideo,
                                    watchGuide: watchGuide
                                )
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getNewArticles(
        category : String = "",
        featuredVideo : Bool = false,
        searchString : String = "",
        site : Site = Site.ethos,
        forViewAll : Bool = false
    ) {
        if !self.gettingNewArticles,
           let dataCount = currentDataCount,
           dataCount >= limit,
           self.articles.count <= totalCount {
            currentOffset += limit
            self.gettingNewArticles = true
            self.delegate?.startFooterIndicator()
            EthosApiManager().callApi(
                endPoint: forViewAll ? EthosApiEndPoints.getViewAllArticles : EthosApiEndPoints.getArticles,
                RequestType: .GET,
                RequestParameters: [
                    EthosConstants.offset: String(self.currentOffset),
                    EthosConstants.limit : String(limit),
                    EthosConstants.category : category,
                    EthosConstants.site : site.rawValue,
                    EthosConstants.featuredVideo : featuredVideo ? "1" : "0",
                    EthosConstants.searchStr : searchString
                ],
                RequestBody: [:]
            ){ data, response, error in
                self.gettingNewArticles = false
                self.delegate?.stopFooterIndicator()
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let data = data {
                            DispatchQueue.main.async {
                                if let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                                    print(json)
                                    let getArticleModel = GetArticles(json: json)
                                    self.articles.append(contentsOf: getArticleModel.data?.articles ?? [])
                                    self.advertisements.append(contentsOf: getArticleModel.data?.advertisements ?? [])
                                    self.currentOffset = getArticleModel.data?.currentOffset ?? 0
                                    self.adRepeatAfter = getArticleModel.data?.adRepeatAfter ?? 0
                                    self.currentDataCount = getArticleModel.data?.currentDataCount ?? 0
                                    self.totalCount = getArticleModel.data?.totalCount ?? 0
                                    
                                    self.delegate?.didGetArticles(category: category, offset: self.currentOffset, limit: self.limit, articleModel: getArticleModel, site: site, searchString: searchString, featuredVideo: featuredVideo, watchGuide: false)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
