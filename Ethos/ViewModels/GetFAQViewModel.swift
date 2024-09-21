//
//  GetFAQViewModel.swift
//  Ethos
//
//  Created by mac on 19/09/23.
//

import Foundation

class GetFAQViewModel {
    
    var faqList = [FAQ]()
    var categories = [FAQCategory]()
    var filteredFaqs = [FAQ]()
    
    var delegate : GetFAQViewModelDelegate?
    
    func getFAQList (
        site : Site = .ethos,
        category : Int? = nil
    ) {
        var reqParams = [EthosConstants.site : site.rawValue]
        if let id = category {
            reqParams[EthosConstants.category] = String(id)
        }
        self.delegate?.startIndicator()
        
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.getFAQ, RequestType: .GET, RequestParameters: reqParams , RequestBody: [:]) { data , response, error in
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200,
               let data = data,
               let datamodel = try? JSONDecoder().decode(GetFAQ.self, from: data) {
                self.faqList = datamodel.data?.faqs ?? []
                self.delegate?.didGetFAQ()
            }
        }
    }
    
    func getFAQCategories(site : Site = .ethos) {
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.getFAQCategories, RequestType: .GET, RequestParameters: [EthosConstants.site : site.rawValue], RequestBody: [:]) { data , response, error in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if let data = data {
                        DispatchQueue.main.async {
                            if let datamodel = try? JSONDecoder().decode(GetFAQCategories.self, from: data) {
                                self.categories = datamodel.data?.categories ?? []
                                self.delegate?.didGetFAQCategories()
                            }
                        }
                    }
                }
            }
        }
    }
}



protocol GetFAQViewModelDelegate {
    func didGetFAQ()
    func didGetFAQCategories()
    func startIndicator()
    func stopIndicator()
}



struct GetFAQCategories: Codable {
    var status: Bool?
    var data: GetFAQCategoriesData?
    var error: String?
}


struct GetFAQCategoriesData: Codable {
    var categories: [FAQCategory]?
}


struct FAQCategory: Codable {
    var id: Int?
    var name: String?
    var image: String?
    var description: String?
    var children: [FAQCategory]?
    var parent: Int?
}

struct GetFAQ: Codable {
    var status: Bool?
    var data: GetFAQData?
    var error: String?
}


struct GetFAQData: Codable {
    var faqs: [FAQ]?
}


struct FAQ: Codable {
    var id: Int?
    var question, answer: String?
}

