//
//  ShoppingCategoryTableViewCell.swift
//  Ethos
//
//  Created by mac on 27/06/23.
//

import UIKit
import SkeletonView

class ShoppingCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageCategory: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnShopNow: UIButton!
    @IBOutlet weak var disclosureArrow: UIImageView!
    @IBOutlet weak var constraintHeightMainImage: NSLayoutConstraint!
    @IBOutlet weak var constraintAspectRatio: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
        self.lblTitle.skeletonTextNumberOfLines = 1
        self.lblTitle.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
        self.lblTitle.skeletonLineSpacing = 10
    }
    
    var category : CategoryNameId? {
        didSet {
            self.lblTitle.text = category?.name
            if let image = category?.image, let url = URL(string: image) {
                self.imageCategory.kf.setImage(with: url)
            }
        }
    }
    
    func setUI(){
        self.imageCategory.setBorder(borderWidth: 0, borderColor: .clear, radius: 40)
    }
}
