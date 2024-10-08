//
//  FavreLeubaCollectionReusableView.swift
//  Ethos
//
//  Created by mac on 01/12/23.
//

import UIKit

class FavreLeubaCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var imageViewMain: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var btnAction: UIButton!
    
    var delegate : SuperViewDelegate?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI(isExpanded: false)
    }
    
    func setUI(isExpanded : Bool) {
        lblTitle.numberOfLines = 0
        self.lblDescription.numberOfLines = isExpanded ? 0 : 4
        
        self.lblTitle.setAttributedTitleWithProperties(title: "FAVRE LEUBA\nCONQUERING FRONTIERS FOR 287 YEARS", font: EthosFont.Brother1816Medium(size: 12), lineHeightMultiple: 1.5, kern: 1)
        self.lblDescription.setAttributedTitleWithProperties(title: "Founded in 1737, Favre Leuba was born inside the mind of Abraham Favre, the “master watchmaker” of Le Locle, Switzerland, who is also considered one of the first Swiss watchmakers in the world. Through decades of globetrotting, unparalleled prowess in the craft of watchmaking, and an unmistakable design DNA, Favre Leuba soon became an icon of the horological universe. In the 1960s, Favre Leuba became widely recognised for its tool-like instrument watches with timepieces such as the Bathy, Deep Blue, and Bivouac.", font: EthosFont.Brother1816Regular(size: 12), lineHeightMultiple: 1.3, kern: 0.5)
        
        self.btnAction.setAttributedTitleWithProperties(title: isExpanded ? "Read Less" : "Read More", font: EthosFont.Brother1816Regular(size: 12), kern: 0.5, showUnderline: true, underLineStyle: .thick)
        
        self.layoutIfNeeded()
    }
    
}
