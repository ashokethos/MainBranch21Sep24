//
//  GetGlossaryViewModel.swift
//  Ethos
//
//  Created by SoftGrid on 21/07/23.
//

import Foundation

class GetGlossaryViewModel {
    
    var glossary = [GlossaryHeading]()
    var selectedIndex = 0
    var delegate : GetGlossaryViewModelDelegate?
    
    func getGlossaryData (
        site : Site
    ) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi (
            endPoint: EthosApiEndPoints.getGlossary,
            RequestType: .GET,
            RequestParameters: [EthosConstants.site : site.rawValue],
            RequestBody: [:]
        ) { data, response, error in
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200,
               let data = data,
               let jsonData = try? JSONSerialization.jsonObject(with: data) as? [String:Any] {
                DispatchQueue.main.async {
                    let sortedDictionaryArr = jsonData.keys.sorted { a, b in
                        b.lowercased() > a.lowercased()
                    }
                    var arrHeader = [GlossaryHeading]()
                    for letter in sortedDictionaryArr {
                        let model = GlossaryHeading(header: letter)
                        model.data = self.getData(dictGlossary: jsonData, header: letter)
                        arrHeader.append(model)
                    }
                    
                    self.glossary = arrHeader
                    self.delegate?.didGetGlossary()
                }
            }
        }
    }
    
    private func getData(
        dictGlossary: [String: Any],
        header : String
    ) -> [Glossary] {
        if let dictionaryWords =
            dictGlossary[header.lowercased()] as? [String:Any] {
            var ArrModel = [Glossary]()
            for (_, value) in dictionaryWords {
                let dict = value as? [String:Any]
                let glossaryModel = Glossary (
                    postId: dict?[EthosConstants.postId] as? Int,
                    title: (dict?[EthosConstants.title] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
                    link :  dict?[EthosConstants.link] as? String,
                    content:  (dict?[EthosConstants.content] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                ArrModel.append(glossaryModel)
            }
            return ArrModel.sorted { model1, model2 in
                model2.title?.lowercased() ?? "" > model1.title?.lowercased() ?? ""
            }
        }
        return [Glossary]()
    }
}
