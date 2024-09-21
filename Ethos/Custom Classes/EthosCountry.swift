//
//  EthosCountry.swift
//  Ethos
//
//  Created by mac on 01/08/23.
//

import Foundation
import UIKit

class CountryViewModel : NSObject {
    
    var countries : [Country] = []
    
    func filteredCountries(str : String) -> [Country] {
        if str == "" {
            return self.countries
        } else {
            let filteredArr = countries.filter { country in
                return (country.name?.lowercased().contains(str.lowercased()) ?? false) ||  (country.dialCode?.lowercased().contains(str.lowercased()) ?? false) || (country.code?.lowercased().contains(str.lowercased()) ?? false)
            }
            return filteredArr
        }
        
    }
    
    func loadCountries() {
        do {
            if let bundlePath = Bundle.main.path(forResource: "Countries", ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                if let json = try? JSONDecoder().decode([Country].self, from: jsonData) {
                    self.countries = json
                } else {
                    print("Error")
                }
            }
        } catch {
            print(error)
        }
    }
}
