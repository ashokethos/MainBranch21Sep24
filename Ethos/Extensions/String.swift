//
//  String.swift
//  Ethos
//
//  Created by mac on 31/07/23.
//

import Foundation
import libPhoneNumber

extension String {
    
    var getInt : Int {
        let tmp1 = self.trimmingCharacters(in: .whitespacesAndNewlines)
        let tmp2 = tmp1.replacingOccurrences(of: ",", with: "")
        let tmp3 = tmp2.components(separatedBy: "-")
        
        if let firstValue = tmp3.first?.digits {
            let intFirst = Int(firstValue)
            return intFirst ?? 0
        } else {
            return 0
        }
    }
    
    var isBlank: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty
    }
    
    var isValidEmail : Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        let result = predicate.evaluate(with: self)
        
        if result == true {
            let results = self.components(separatedBy: ".")
            if let topLevelDomain = results.last?.lowercased(), self.getValidDomains().contains(topLevelDomain) {
                return true
            } else {
                return false
            }
        } else {
            return result
        }
    }
    
    var digits: String {
           return components(separatedBy: CharacterSet.decimalDigits.inverted)
               .joined()
       }
    
    func isValidPhoneNumber(region : String) -> Bool {
        let dataHelper = NBMetadataHelper()
        
        if let util = NBPhoneNumberUtil(metadataHelper: dataHelper), let number = try? util.parse(self, defaultRegion: region) {
            return util.isValidNumber(number)
        } else {
            let regex = "^[0-9]\\d{9}$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            let result = predicate.evaluate(with: self)
            return result
        }
    }
    
    var containsOneSmallLetter : Bool {
        let regex = ".*[a-z]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = predicate.evaluate(with: self)
        return result
    }
    
    var containsOneCapitalLetter : Bool {
        let regex = ".*[A-Z]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = predicate.evaluate(with: self)
        return result
    }
    
    var containsOneSpecialCharacterForNCS : Bool {
        let regex = ".*[-+_!@#$%^&*.,?]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = predicate.evaluate(with: self)
        return result
    }
    
    var containsHtmlCharacters : Bool {
        if self.contains("<") || self.contains(">") || self.contains("/") {
            return true
        } else {
            return false
        }
    }
    
    var containsOneSpecialCharacter : Bool {
        let regex = ".*[-+_!@#$%^&*., ?]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = predicate.evaluate(with: self)
        return result
    }
    
    var containsOneNumericValue : Bool {
        let regex = ".*[0-9]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = predicate.evaluate(with: self)
        return result
    }
    
    var containsValidCharacter: Bool {
        guard self != "" else { return true }
        let hexSet = CharacterSet(charactersIn: "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
        let newSet = CharacterSet(charactersIn: self)
        return hexSet.isSuperset(of: newSet)
      }
    
    var htmlToAttributedString: NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    var emailUrl : String {
        let email = self.replacingOccurrences(of: " " , with:  "")
        return "mailto:\(email)"
    }
    
    var phoneNumberUrl : String {
        let phoneNumber = self.replacingOccurrences(of: " " , with:  "")
        return "tel://\(phoneNumber)"
    }
    
    
    
    func getVimeoId() -> String {
        let videoId = self.replacingOccurrences(of: "https://player.vimeo.com/video/", with: "")
        return videoId.replacingOccurrences(of: "\r\n", with: "")
    }
    
    func getValidDomains() -> [String] {
        do {
            if let bundlePath = Bundle.main.path(forResource: "ValidDomains", ofType: "txt") {
                let stringContent = try String(contentsOfFile: bundlePath)
                let arrValidDomains = stringContent.components(separatedBy: .newlines).filter { str in
                    str != ""
                }.map { str in
                    str.lowercased()
                }
                return arrValidDomains
                
            } else {
                return []
            }
        } catch {
            return []
        }
    }
    
    func shorted(to symbols: Int) -> String {
        guard self.count > symbols else {
            return self
        }
        return self.prefix(symbols) + " ..."
    }
    
    
    func getFirstNameAndLastNameFromString() -> (String , String){
        var firstname = ""
        var lastname = ""
        var components = self.components(separatedBy: .whitespaces)
        
        components.removeAll { str in
            str == ""
        }
        
        if components.count == 0 {
            
        } else if components.count == 1 {
            firstname = components[safe : 0] ?? ""
        } else if components.count == 2 {
            firstname = components[safe : 0] ?? ""
            lastname = components[safe : 1] ?? ""
        } else  if components.count == 3 {
            firstname = (components[safe : 0] ?? "") + " " + (components[safe : 1] ?? "")
            lastname = components[safe : 2] ?? ""
        } else if components.count > 3 {
            lastname = components.last ?? ""
            components.removeLast()
            for (index,word) in components.enumerated() {
                if index == 0 {
                    firstname.append(word)
                } else {
                    firstname.append(" " + word)
                }
            }
        }
        return (firstname , lastname)
    }
    
    func getAttributedString<T>(_ key: NSAttributedString.Key, value: T) -> NSAttributedString {
           let applyAttribute = [ key: T.self ]
           let attrString = NSAttributedString(string: self, attributes: applyAttribute)
           return attrString
        }
    
    var isValidURL: Bool {
            let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
                // it is a link, if the match covers the whole string
                return match.range.length == self.utf16.count
            } else {
                return false
            }
        }
}


extension Bool {
    var negated: Bool { !self }
}

extension StringProtocol {
    func separate(every stride: Int = 4, from start: Int = 0, with separator: Character = " ") -> String {
        .init(enumerated().flatMap { $0 != 0 && ($0 == start || $0 % stride == start) ? [separator, $1] : [$1]})
    }
}
