//
//  Int.swift
//  Ethos
//
//  Created by mac on 25/10/23.
//

import UIKit

extension Int {
    func getCommaSeperatedStringValue() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:self))
        return formattedNumber
    }
}

extension Double {
    func getCommaSeperatedStringValue() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:self))
        return formattedNumber
    }
}
