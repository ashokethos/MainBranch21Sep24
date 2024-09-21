//
//  SubText.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class SubText {
    var heading: String?
    var text: String?
    var mainHeading: String?
    var order: Int?
    var image: String?

    init(heading: String?, text: String?, mainHeading: String?, order: Int?, image: String?) {
        self.heading = heading
        self.text = text
        self.mainHeading = mainHeading
        self.order = order
        self.image = image
    }
    
    init(json : [String : Any]) {
        if let heading = json[EthosConstants.heading] as? String {
            self.heading = heading
        }
        
        if let image = json[EthosConstants.image] as? String {
            self.image = image
        }
        
        if let order = json[EthosConstants.order] as? Int {
            self.order = order
        }
        
        if let text = json[EthosConstants.text] as? String {
            self.text = text
        }
        
        if let mainHeading = json[EthosConstants.mainHeading] as? String {
            self.mainHeading = mainHeading
        }
    }
}
