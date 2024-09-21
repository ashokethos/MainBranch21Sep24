//
//  Formatter.swift
//  Ethos
//
//  Created by mac on 27/02/24.
//

import Foundation

extension Formatter {
    static let today: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.defaultDate = Calendar.current.startOfDay(for: Date())
        dateFormatter.dateFormat = "hh:mma"
        return dateFormatter
    }()
}
