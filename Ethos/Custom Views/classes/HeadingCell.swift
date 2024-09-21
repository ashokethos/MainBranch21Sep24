//
//  HeadingCell.swift
//  Ethos
//
//  Created by mac on 27/06/23.
//

import UIKit

class HeadingCell: UITableViewCell {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var btnDisclosure: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var btnTitle: UIButton!
    @IBOutlet weak var constraintHeightImageView: NSLayoutConstraint!
    @IBOutlet weak var constraintAspectRatio: NSLayoutConstraint!
    @IBOutlet weak var viewUnderLine: UIView!
    @IBOutlet weak var constraintSpacingImageAndTitle: NSLayoutConstraint!
    @IBOutlet weak var constraintLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintTraillingBtnDisclosure: NSLayoutConstraint!
    @IBOutlet weak var constraintWidthDisClosureImage: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightDisclosureImage: NSLayoutConstraint!
    @IBOutlet weak var bulletLine: UIImageView!
    @IBOutlet weak var constraintTraillingBullet: NSLayoutConstraint!
    
    @IBOutlet weak var topLine: UIView!
    
    @IBOutlet weak var constraintTopSpacingButton: NSLayoutConstraint!
    
    @IBOutlet weak var constraintTopSpacingTitle: NSLayoutConstraint!
    
    @IBOutlet weak var constraintBottomSpacingTitle: NSLayoutConstraint!
    
    @IBOutlet weak var constraintBottomSpacingButton: NSLayoutConstraint!
    
    var indexPath : IndexPath?
    
    
    var action : (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func setHeading(
        title : String,
        textColor : UIColor = .black,
        backgroundColor : UIColor = .clear,
        font : UIFont? = nil,
        numberOfLines : Int = 1,
        alignment : NSTextAlignment? = nil,
        image : UIImage? = nil,
        imageHeight: CGFloat = 0,
        spacingTitleImage : CGFloat = 0,
        leading : CGFloat = 30,
        trailling : CGFloat = 30,
        showDisclosure : Bool = false,
        isSelected : Bool = false,
        disclosureImageDefault : UIImage? = nil,
        disclosureImageSelected : UIImage? = nil,
        disclosureTitleDefault : String = "",
        disclosureTitleSelected : String = "",
        disclosureHeight : CGFloat = 0,
        disclosureWidth : CGFloat = 0,
        showUnderLine : Bool = false,
        showTopLine : Bool = false,
        underlineColor : UIColor = .black,
        toplineColor : UIColor = .black,
        AspectRationConstant : CGFloat = 0,
        showBulletLine : Bool = false,
        traillingBulletLine : CGFloat = 0,
        action : (() -> ())? = nil,
        topSpacing : CGFloat = 0,
        bottomSpacing : CGFloat = 0
    ) {
        self.backgroundColor = backgroundColor
        self.titleLabel.text = title
        self.titleLabel.numberOfLines = numberOfLines
        self.titleLabel.textColor = textColor
        self.constraintHeightImageView.constant = imageHeight
        self.constraintAspectRatio.constant = AspectRationConstant
        self.constraintSpacingImageAndTitle.constant = spacingTitleImage
        self.constraintLeading.constant = leading
        self.constraintTraillingBtnDisclosure.constant = trailling
        self.constraintHeightDisclosureImage.constant = disclosureHeight
        self.constraintWidthDisClosureImage.constant = disclosureWidth
        self.constraintTraillingBullet.constant = traillingBulletLine
        self.constraintTopSpacingTitle.constant = topSpacing
        self.constraintBottomSpacingTitle.constant = bottomSpacing
        self.constraintTopSpacingButton.constant = topSpacing
        self.constraintBottomSpacingButton.constant = bottomSpacing
        self.viewUnderLine.isHidden = !showUnderLine
        self.topLine.isHidden = !showTopLine
        self.viewUnderLine.backgroundColor = underlineColor
        self.topLine.backgroundColor = toplineColor
        self.btnDisclosure.setTitle(disclosureTitleDefault, for: .normal)
        self.btnDisclosure.setTitle(disclosureTitleSelected, for: .selected)
        
        if let disclosureImageDefault = disclosureImageDefault {
            self.btnDisclosure.setImage(disclosureImageDefault, for: .normal)
        }
        
        if let disclosureImageSelected = disclosureImageSelected {
            self.btnDisclosure.setImage(disclosureImageSelected, for: .selected)
        }
        
        if let font = font {
            self.titleLabel.font = font
        }
        
        if let alignment = alignment {
            self.titleLabel.textAlignment = alignment
        }
        
        if let image = image {
            self.mainImageView.image = image
        }
        
        
        if let action = action {
            self.btnTitle.isUserInteractionEnabled = true
            self.action = action
        } else {
            self.btnTitle.isUserInteractionEnabled = false
            self.btnTitle.isHidden = true
        }
        
        self.btnDisclosure.isSelected = isSelected
        self.bulletLine.isHidden = !showBulletLine
    }
    
    
    @IBAction func didTap(_ sender: UIButton) {
        (action ?? {
            
        })()
    }
    
    override func prepareForReuse() {
        self.titleLabel.isHidden = false
    }
    
}
