//
//  GetArticleDetailsViewModelDelegate.swift
//  Ethos
//
//  Created by mac on 04/09/23.
//

import Foundation

protocol GetArticleDetailsViewModelDelegate {
    func didGetArticledetails(articleDetails : ArticleDetails)
    func errorInGettinArticles()
    func startIndicator()
    func stopIndicator()
}
