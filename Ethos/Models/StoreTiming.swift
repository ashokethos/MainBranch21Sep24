//
//  StoreTiming.swift
//  Ethos
//
//  Created by mac on 26/02/24.
//

import UIKit

class StoreTiming: NSObject {
    var startTime : String?
    var endTime : String?
    var day : String?
    
    init(startTime: String? = nil, endTime: String? = nil, day: String? = nil) {
        self.startTime = startTime
        self.endTime = endTime
        self.day = day
    }
    
    init(string : String) {
        let components = string.components(separatedBy: .whitespaces)
        
        var actualComponents = components.filter { str in
            str != "" && str != " "
        }
        
        if (actualComponents.first?.lowercased().contains("day")) ?? false {
            self.day = actualComponents.first
            actualComponents.removeFirst()
            
            if actualComponents.count >= 1 {
                let startAndEndTime = actualComponents.joined(separator: "")
                
                var componentsOfTiming = [String]()
                
                if startAndEndTime.contains("to") {
                   componentsOfTiming = startAndEndTime.components(separatedBy: "to")
                }
                
                if startAndEndTime.contains("To") {
                   componentsOfTiming = startAndEndTime.components(separatedBy: "To")
                }
                
                if startAndEndTime.contains("-") {
                   componentsOfTiming = startAndEndTime.components(separatedBy: "-")
                }
                
                if startAndEndTime.contains("TO") {
                   componentsOfTiming = startAndEndTime.components(separatedBy: "-")
                }
                
                let actualComponentsOfTiming  = componentsOfTiming.filter { str in
                    str != "" && str != " "
                }
                
                if actualComponentsOfTiming.count >= 1 {
                    self.startTime = actualComponentsOfTiming.first
                }
                
                if actualComponentsOfTiming.count >= 2 {
                    self.endTime = actualComponentsOfTiming[1]
                }
            }
        } else {
            if actualComponents.count >= 1 {
                let startAndEndTime = actualComponents.joined(separator: "")
                
                var componentsOfTiming = [String]()
                
                if startAndEndTime.contains("to") {
                   componentsOfTiming = startAndEndTime.components(separatedBy: "to")
                }
                
                if startAndEndTime.contains("To") {
                   componentsOfTiming = startAndEndTime.components(separatedBy: "To")
                }
                
                if startAndEndTime.contains("-") {
                   componentsOfTiming = startAndEndTime.components(separatedBy: "-")
                }
                
                if startAndEndTime.contains("TO") {
                   componentsOfTiming = startAndEndTime.components(separatedBy: "TO")
                }
                
                
                let actualComponentsOfTiming  = componentsOfTiming.filter { str in
                    str != "" && str != " "
                }
                
                if actualComponentsOfTiming.count >= 1 {
                    self.startTime = actualComponentsOfTiming.first
                   
                }
                
                if actualComponentsOfTiming.count >= 2 {
                    self.endTime = actualComponentsOfTiming[1]
                }
            }
        }
    }
}
