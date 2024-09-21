//
//  CornerCutImageTableViewCell.swift
//  Ethos
//
//  Created by mac on 04/12/23.
//

import UIKit

class CornerCutImageTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imageViewMain: UIImageView!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var constraintHeightImage: NSLayoutConstraint!
    @IBOutlet weak var constraintHeadingBottom: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        self.imageViewMain.image = nil
        self.imageViewMain.mask = nil
        self.lblType.setAttributedTitleWithProperties(title: "", font: EthosFont.Brother1816Regular(size: 12))
        self.lblHeading.setAttributedTitleWithProperties(title: "", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24))
        self.lblDescription.setAttributedTitleWithProperties(title: "", font: EthosFont.Brother1816Regular(size: 12))
        self.constraintHeightImage.constant = 0
    }
    
    var data : SubText? {
        didSet {
            if let image = data?.image {
                constraintHeightImage.constant = self.imageViewMain.bounds.size.width
                UIImage.loadFromURL(url: image) { img in
                    self.imageViewMain.image = img
                }
            } else {
                constraintHeightImage.constant = 0
            }
            
            if let heading = data?.heading {
                lblHeading.setAttributedTitleWithProperties(title: heading.uppercased(), font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24), lineHeightMultiple: 1.3, kern: 0.5)
            }
            
            if let mainHeading = data?.mainHeading {
                lblType.setAttributedTitleWithProperties(title: mainHeading.uppercased(), font: EthosFont.Brother1816Regular(size: 14), lineHeightMultiple: 1.3, kern: 0.5)
            }
            
            if let content = data?.text {
                if data?.heading == nil || data?.heading == ""{
                    constraintHeadingBottom.constant = 0
                }else{
                    constraintHeadingBottom.constant = 32
                }
                lblDescription.setAttributedTitleWithProperties(title: content, font: EthosFont.Brother1816Regular(size: 14), lineHeightMultiple: 1.3, kern: 0.5)
            }
        }
    }
    
    
}
