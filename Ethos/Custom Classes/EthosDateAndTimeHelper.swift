//
//  EthosDateAndTimeHelper.swift
//  Ethos
//
//  Created by SoftGrid on 14/07/23.
//

import Foundation

class EthosDateAndTimeHelper {
    
    func getStringFromTimeStamp(timeStamp : Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, YYYY"
        return dateFormatter.string(from: date)
    }
    
    func getTimeStampFromUTCString(str: String) -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: str) ?? Date()
        return date.timeIntervalSince1970
    }
    
    func getStringFromDate(str : String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: str) ?? Date()
        dateFormatter.dateFormat = "MMMM dd, YYYY"
        return dateFormatter.string(from: date)
    }
    
    func getWelcomeTimeString() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Date().dateFormatWithSuffix()
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date).uppercased()
    }
    
}
