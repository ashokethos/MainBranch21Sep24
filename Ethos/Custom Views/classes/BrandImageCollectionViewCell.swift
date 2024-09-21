//
//  BrandImageCollectionViewCell.swift
//  Ethos
//
//  Created by mac on 29/08/23.
//

import UIKit

class BrandImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainImage : UIImageView!
    
    @IBOutlet weak var constraintHeightImage: NSLayoutConstraint!
    @IBOutlet weak var constraintWidthImage: NSLayoutConstraint!
    
    var index = IndexPath()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setBorderAccordingToIndex(index : Int, totalCount : Int, numberOfItemsInColumn : Int = 4, numberOfItemsInRow : Int = 3) {
        
        let remainder = totalCount%numberOfItemsInColumn
         
        if remainder == 0 {
            if index >= (totalCount - numberOfItemsInColumn) {
                self.addBorders(edges: [.bottom], color: EthosColor.appBGColor, inset: 0, thickness: 1)
            } else {
                self.addBorders(edges: [.right, .bottom], color: EthosColor.appBGColor, inset: 0, thickness: 1)
            }
        } else {
            if index >= (totalCount - remainder) {
                self.addBorders(edges: [.bottom], color: EthosColor.appBGColor, inset: 0, thickness: 1)
            } else {
                self.addBorders(edges: [.right, .bottom], color: EthosColor.appBGColor, inset: 0, thickness: 1)
            }
        }
        
    }
    
    override func prepareForReuse() {
        
    }
    
    var brand : BrandModel? {
        
        didSet {
            if let imageOfBrand = brand?.image, let imageUrl = URL(string: imageOfBrand) {
                self.mainImage.kf.setImage(with: imageUrl)
            }
        }
    }
}
