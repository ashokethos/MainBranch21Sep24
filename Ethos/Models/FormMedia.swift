//
//  FormMedia.swift
//  Ethos
//
//  Created by mac on 11/09/23.
//

import UIKit


struct FormMedia {
    var key : String
    let fileName: String
    let data: Data
    let mimeType: String

    init?(withImage image: UIImage, key : String) {
        self.mimeType = EthosConstants.imageJPG 
        self.fileName = "\(arc4random()).jpeg"
        guard let data = image.jpegData(compressionQuality: 0.5) else { return nil }
        self.key = key
        self.data = data
    }
}
