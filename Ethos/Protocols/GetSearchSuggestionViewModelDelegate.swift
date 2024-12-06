//
//  GetSearchSuggestionViewModelDelegate.swift
//  Ethos
//
//  Created by Ashok kumar on 12/07/24.
//

import Foundation

protocol GetSearchSuggestionViewModelDelegate {
    func didGetSearchSuggestion(searchSuggestionModel : GetSearchSuggestion, site : Site, searchString : String)
    func errorInGettingArticles(error : String)
    func startIndicators()
    func stopIndicators()
}

