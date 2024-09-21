//
//  GetArticleCategoriesViewModelDelegate.swift
//  Ethos
//
//  Created by mac on 31/08/23.
//

import Foundation


protocol GetArticleCategoriesViewModelDelegate {
    func didGetArticleCategories(articleCategories : [ArticlesCategory])
    func startIndicator()
    func stopIndicator()
}
