//
//  AboutCollectionTableViewCell.swift
//  Ethos
//
//  Created by mac on 06/07/23.
//

import UIKit

class AboutCollectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewBottomLine: UIView!
    @IBOutlet weak var constraintBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintSpacingImageDescription: NSLayoutConstraint!
    @IBOutlet weak var constraintSpacingTitleImage: NSLayoutConstraint!
    @IBOutlet weak var constraintTopSpacingTitle: NSLayoutConstraint!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var constraintLeadingDescription: NSLayoutConstraint!
    @IBOutlet weak var constraintLeadingTitle: NSLayoutConstraint!
    @IBOutlet weak var constraintTrailingTitle: NSLayoutConstraint!
    @IBOutlet weak var constraintTrailingDescription: NSLayoutConstraint!
    @IBOutlet weak var constraintTrailingImage: NSLayoutConstraint!
    @IBOutlet weak var constraintLeadingImage: NSLayoutConstraint!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var constraintHeight: NSLayoutConstraint!
    
    var index = 0
    
    var key : AboutCollectionKeys = .forRepairAndService {
        didSet {
            switch key {
            case .forRepairAndService:
                self.img.contentMode = .scaleAspectFill
                self.constraintHeight.constant = self.img.frame.size.width*193/328
                
                self.constraintLeadingImage.constant = 30
                self.constraintTrailingImage.constant = 30
                
                self.constraintSpacingTitleImage.constant = 20
                
                self.constraintTopSpacingTitle.constant = 20
                
                self.constraintLeadingDescription.constant = 30
                self.constraintTrailingDescription.constant = 30
                
                self.constraintBottom.constant = 20
                
                self.constraintLeadingTitle.constant = 20
                self.constraintTrailingTitle.constant = 20
                self.viewBottomLine.isHidden = false
                
                
            case .forSecondMovementSell:
                self.img.contentMode = .scaleAspectFit
                self.img.image = UIImage.imageWithName(name: EthosConstants.sellOrTradeWithShadow)
              
                self.constraintLeadingImage.constant = 0
                self.constraintTrailingImage.constant = 0
                
                self.constraintSpacingTitleImage.constant = 0
                self.constraintTopSpacingTitle.constant = 20
                
                self.constraintLeadingDescription.constant = 30
                self.constraintTrailingDescription.constant = 30
                
                self.constraintBottom.constant = 20
                
                self.constraintLeadingTitle.constant = 30
                self.constraintTrailingTitle.constant = 30
                self.viewBottomLine.isHidden = true
                
            }
            
            self.contentView.layoutIfNeeded()
        }
    }
    
    var data : TitleDescriptionImageModel? {
        didSet {
            
            self.img.image = UIImage.imageWithName(name: data?.image ?? "")
            
            self.lblDescription.setAttributedTitleWithProperties(title: data?.description ?? "", font: EthosFont.Brother1816Regular(size: 12), lineHeightMultiple: 1.13, kern: 0.1)
            
            switch key {
                
            case .forRepairAndService:
                let title = "\(index). \(data?.title ?? "")"
                self.lblTitle.setAttributedTitleWithProperties(title: title, font: EthosFont.Brother1816Medium(size: 14), lineHeightMultiple: 1.6, kern: 0.5)
            
            case .forSecondMovementSell:
                let title = "\(data?.title ?? "")"
                self.lblTitle.setAttributedTitleWithProperties(title: title, font: EthosFont.Brother1816Medium(size: 14), lineHeightMultiple: 1.6, kern: 0.5)
            }
           
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
