//
//  ProductImageData.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class ProductImageData {
    var catalogImage : String?
    var gallery : [ProductImage] = []
    
    init(catalogImage: String? = nil, gallery : [ProductImage]) {
        self.catalogImage = catalogImage
        self.gallery = gallery
    }
    
    init(json : [String : Any]) {
        if let catalogImage = json[EthosConstants.catalogImage] as? String {
            self.catalogImage = catalogImage
        }
        
        if let galleries = json[EthosConstants.galleries] as? [[String : Any]] {
            var imgArr = [ProductImage]()
            for gallery in galleries {
                let productImage = ProductImage(json: gallery)
                imgArr.append(productImage)
            }
            self.gallery = imgArr.sorted(by: { img1, img2 in
                img2.order ?? 0 > img1.order ?? 0
            })
        }
    }
}
