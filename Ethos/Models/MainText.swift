//
//  MainText.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class MainText {
    var heading: String?
    var image: String?
    var image2: String?
    var image3: String?
    var text: String?

    init(heading: String?, image: String?, image2: String?, image3: String?, text: String?) {
        self.heading = heading
        self.image = image
        self.image2 = image2
        self.image3 = image3
        self.text = text
    }
    
    init(json : [String : Any]) {
        if let heading = json[EthosConstants.heading] as? String {
            self.heading = heading
        }
        
        if let image = json[EthosConstants.image] as? String {
            self.image = image
        }
        
        if let image2 = json[EthosConstants.image2] as? String {
            self.image2 = image2
        }
        
        if let image3 = json[EthosConstants.image3] as? String {
            self.image3 = image3
        }
        
        if let text = json[EthosConstants.text] as? String {
            self.text = text
        }
    }
}
