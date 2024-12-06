//
//  LatestViewModelDelegate.swift
//  Ethos
//
//  Created by SoftGrid on 14/07/23.
//

import Foundation

protocol GetArticlesViewModelDelegate {
    func didGetArticles(category: String, offset: Int, limit: Int, articleModel : GetArticles, site : Site, searchString : String, featuredVideo : Bool, watchGuide : Bool)
    func errorInGettingArticles(error : String)
    func startIndicatorArticle()
    func stopIndicatorArticle()
    func startFooterIndicator()
    func stopFooterIndicator()
}
