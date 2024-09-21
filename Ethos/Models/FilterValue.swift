//
//  FilterValue.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

//class FilterValue : NSObject {
//    
//    var attributeValueId : Int?
//    var attributeValueName : String?
//    
//    init(attributeValueId: Int? = nil, attributeValueName: String? = nil) {
//        self.attributeValueId = attributeValueId
//        self.attributeValueName = attributeValueName
//    }
//    
//    init(json : [String : Any]) {
//        if let id = json[EthosConstants.attrValueID] as? Int {
//            self.attributeValueId = id
//        } else if let id = json[EthosConstants.attrValueID] as? String {
//            self.attributeValueId = Int(id)
//        }
//        
//        if let name = json[EthosConstants.attrValueName] as? String {
//            self.attributeValueName = name
//        }
//    }
//}

//class FilterValue: NSObject {
//    
//    var attributeValueId: Int?
//    var attributeValueName: String?
//    
//    init(attributeValueId: Int? = nil, attributeValueName: String? = nil) {
//        self.attributeValueId = attributeValueId
//        self.attributeValueName = attributeValueName
//    }
//    
//    init(json: [String: Any]) {
//        if let id = json[EthosConstants.attrValueID] as? Int {
//            self.attributeValueId = id
//        } else if let id = json[EthosConstants.attrValueID] as? String {
//            self.attributeValueId = Int(id)
//        }
//        
//        if let name = json[EthosConstants.attrValueName] as? String {
//            self.attributeValueName = name
//        }
//    }
//    
//    // Computed property to extract numeric value from `attributeValueName`
//    var numericValue: Double? {
//        guard let name = attributeValueName else { return nil }
//        let valueString = name.components(separatedBy: " ").first ?? ""
//        return Double(valueString)
//    }
//    
//    // Formatted attribute value for display
//    var formattedValue: String {
//        guard let value = numericValue else { return attributeValueName ?? "" }
//        // Check if the number is an integer
//        if value.truncatingRemainder(dividingBy: 1) == 0 {
//            return String(format: "%.0f mm", value)
//        } else {
//            return String(format: "%.2f mm", value)
//        }
//    }
//    
//    // Static method to sort an array of FilterValue instances
//    static func sortFilterValues(_ values: [FilterValue]) -> [FilterValue] {
//        return values.sorted { (first, second) -> Bool in
//            return (first.numericValue ?? 0) < (second.numericValue ?? 0)
//        }
//    }
//}


class FilterValue: NSObject {
    
    var attributeValueId: Int?
    var attributeValueName: String?
    
    init(attributeValueId: Int? = nil, attributeValueName: String? = nil) {
        self.attributeValueId = attributeValueId
        self.attributeValueName = attributeValueName
    }
    
    init(json: [String: Any]) {
        if let id = json[EthosConstants.attrValueID] as? Int {
            self.attributeValueId = id
        } else if let id = json[EthosConstants.attrValueID] as? String {
            self.attributeValueId = Int(id)
        }
        
        if let name = json[EthosConstants.attrValueName] as? String {
            self.attributeValueName = name
        }
    }
    
    // Computed property to extract the lower bound of the range from `attributeValueName`
    var numericValue: Double? {
        guard let name = attributeValueName else { return nil }
        
        // Regex to extract the first number from the range string
        let regex = try! NSRegularExpression(pattern: "\\d+(?:,\\d+)*", options: [])
        let nsString = name as NSString
        let results = regex.matches(in: name, options: [], range: NSMakeRange(0, nsString.length))
        
        // Extract the first match which represents the lower bound of the range
        if let match = results.first {
            let numberString = nsString.substring(with: match.range)
            let formattedString = numberString.replacingOccurrences(of: ",", with: "")
            return Double(formattedString)
        }
        
        return nil
    }
    
    // Static method to sort an array of FilterValue instances
    static func sortFilterValues(_ values: [FilterValue]) -> [FilterValue] {
        return values.sorted { (first, second) -> Bool in
            return (first.numericValue ?? 0) < (second.numericValue ?? 0)
        }
    }
}
