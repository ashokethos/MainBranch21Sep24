//
//  FilterModel.swift
//  Ethos
//
//  Created by mac on 15/09/23.
//

import Foundation

class FilterModel : NSObject {
    var attributeId : Int?
    var attributeCode : String?
    var attributeName : String?
    var values : [FilterValue]?
    var alphabeticFilterValues : [AlphabeticFilters]?
    
    init(attributeId: Int? = nil, attributeCode: String? = nil, attributeName: String? = nil, values: [FilterValue]? = nil) {
        self.attributeId = attributeId
        self.attributeCode = attributeCode
        self.attributeName = attributeName
        self.values = values
    }
    
    init(json : [String : Any]) {
        if let id = json[EthosConstants.attrId] as? Int {
            self.attributeId = id
        } else if let id = json[EthosConstants.attrId] as? String {
            self.attributeId = Int(id)
        }
        
        if let code = json[EthosConstants.attrCode] as? String {
            self.attributeCode = code
        }
        
        if let name = json[EthosConstants.attrName] as? String {
            self.attributeName = name
        }
        
        if let values = json[EthosConstants.value] as? [[String : Any]] {
            var arrValue = [FilterValue]()
            for value in values {
                let val = FilterValue(json: value)
                arrValue.append(val)
            }
            
            self.values = arrValue
            
            var alphabeticFilterArr = [AlphabeticFilters]()
            
            for alphabet in EthosConstants.alphabets {
                let alphabeticValue = AlphabeticFilters(header: alphabet)
                for value in self.values ?? [] {
                    if let firstCharacter = value.attributeValueName?.first {
                        if EthosConstants.alphabets.contains(where: { alphabet in
                            alphabet.first == firstCharacter
                        }) {
                            if alphabet.first == firstCharacter {
                                alphabeticValue.values.append(value)
                            }
                        } else if alphabet == "#" {
                            alphabeticValue.values.append(value)
                        }
                    }
                }
                
                if alphabeticValue.header == "#" {
                    let values : [FilterValue] = alphabeticValue.values.sorted { v1, v2 in
                        (v2.numericValue ?? 0.0) > (v1.numericValue ?? 0.0)
                    }
                    alphabeticValue.values = values
                }
                
                if alphabeticValue.values.count > 0 {
                    alphabeticFilterArr.append(alphabeticValue)
                }
            }
            self.alphabeticFilterValues = alphabeticFilterArr
        }
    }
    
    func filteredAlphabeticFilterValues(searchString : String) -> [AlphabeticFilters]?  {
        var values = [FilterValue]()
        for alphabeticFilter in self.alphabeticFilterValues ?? [] {
            let valArr =  alphabeticFilter.values.filter({ val in
                val.attributeValueName?.lowercased().contains(searchString.lowercased()) ?? false
            })
            values.append(contentsOf: valArr)
        }
        
        var alphabeticFilterArr = [AlphabeticFilters]()
        
        for alphabet in EthosConstants.alphabets {
            let alphabeticValue = AlphabeticFilters(header: alphabet)
            for value in values {
                if let firstCharacter = value.attributeValueName?.first {
                    if EthosConstants.alphabets.contains(where: { alphabet in
                        alphabet.first == firstCharacter
                    }) {
                        if alphabet.first == firstCharacter {
                            alphabeticValue.values.append(value)
                        }
                    } else if alphabet == "#" {
                        alphabeticValue.values.append(value)
                    }
                }
            }
            
            if alphabeticValue.header == "#" {
                let values : [FilterValue] = alphabeticValue.values.sorted { v1, v2 in
                    (v2.attributeValueName ?? "").getInt > (v1.attributeValueName ?? "").getInt
                }
                alphabeticValue.values = values
            }
            
            if alphabeticValue.values.count > 0 {
                alphabeticFilterArr.append(alphabeticValue)
            }
        }
        
        return alphabeticFilterArr
        
    }
}
