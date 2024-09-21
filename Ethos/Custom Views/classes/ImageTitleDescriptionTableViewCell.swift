//
//  ImageTitleDescriptionTableViewCell.swift
//  Ethos
//
//  Created by mac on 22/09/23.
//

import UIKit

class ImageTitleDescriptionTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var constraintSpacingDisclosureSubTitleAndCTA: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var btnActionDisclosure: UIButton!
    @IBOutlet weak var imageViewMain: UIImageView!
    var delegate : SuperViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        self.btnActionDisclosure.isHidden = false
        self.constraintSpacingDisclosureSubTitleAndCTA.constant = 24
    }
    
    var data : TitleDescriptionImageModel? {
        didSet {
            
            imageViewMain.image = UIImage.imageWithName(name: data?.image ?? "")
            
            lblTitle.setAttributedTitleWithProperties(
                title : data?.title ?? "",
                font : EthosFont.MrsEavesXLSerifNarOTReg(size: 24),
                alignment :  .left,
                foregroundColor : .black,
                lineHeightMultiple : 1.25,
                kern : 0.1
            )
            
            lblSubTitle.setAttributedTitleWithProperties(
                title : data?.description ?? "",
                font : EthosFont.Brother1816Regular(size: 12),
                alignment :  .left,
                foregroundColor : .black,
                lineHeightMultiple : 1,
                kern : 0.1
            )
            
            btnAction.setAttributedTitleWithProperties(
                title : data?.btnTitle ?? "",
                font : EthosFont.Brother1816Regular(size: 10),
                alignment :  .left,
                foregroundColor : .black,
                lineHeightMultiple : 1,
                kern : 0.5
            )
            
            self.btnActionDisclosure.isHidden = (data?.btnTitle == "")
            self.constraintSpacingDisclosureSubTitleAndCTA.constant = (data?.btnTitle == "") ? 0 : 24
        }
        
    }
    
    @IBAction func btnActionDidTapped(_ sender: UIButton) {
        if let data = self.data {
            switch data.btnTitle {
            case EthosConstants.boutiqueButtonTitle_I : break
            case EthosConstants.boutiqueButtonTitle_II :
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.route, EthosKeys.value : String(describing: ContactUsViewController.self)])
            case EthosConstants.boutiqueButtonTitle_III :
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.openWebPage, EthosKeys.url : EthosIdentifiers.qualityAssuranceUrl])
            default : break
                
            }
        }
    }
}
