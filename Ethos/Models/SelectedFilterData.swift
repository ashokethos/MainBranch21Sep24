//
//  SelectedFilterData.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class SelectedFilterData : NSObject {
    var filterModelName : String
    var filterModelCode : String
    var filterModelId : Int
    var filtervalue : FilterValue
    
    init(filterModelName: String, filterModelCode: String, filterModelId: Int, filtervalue: FilterValue) {
        self.filterModelName = filterModelName
        self.filterModelCode = filterModelCode
        self.filterModelId = filterModelId
        self.filtervalue = filtervalue
    }
}
