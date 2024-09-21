//
//  Data.swift
//  Ethos
//
//  Created by mac on 11/09/23.
//

import Foundation

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
    
    var html2AttributedString: NSAttributedString? {
        return try? NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        
    }
    
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
