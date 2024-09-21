//
//  SecondMovementBoutiqueHeaderTableViewCell.swift
//  Ethos
//
//  Created by mac on 22/09/23.
//

import UIKit

class SecondMovementBoutiqueHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblMainTilte: UILabel!
    @IBOutlet weak var lblMainSubTitle: UILabel!
    @IBOutlet weak var imageOverlay: UIImageView!
    @IBOutlet weak var imageViewMain: UIImageView!
    @IBOutlet weak var lblMainDescription: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }

    func setUI() {
        
        lblMainTilte.setAttributedTitleWithProperties(
            title : "Second\nMovement".uppercased(),
            font : EthosFont.MrsEavesXLSerifNarOTReg(size: 32),
            alignment :  .center,
            foregroundColor : .white,
            lineHeightMultiple : 1.35,
            kern : 3.4
        )
        
        lblMainSubTitle.setAttributedTitleWithProperties(
            title : "A premium lounge where you can experience the finest pre-owned luxury watches",
            font : EthosFont.Brother1816Regular(size: 12),
            alignment :  .center,
            foregroundColor : .white,
            lineHeightMultiple : 1.2,
            kern : 0.1
        )
        
        lblMainDescription.setAttributedTitleWithProperties(
            title : "Ethos Watch Boutiques brings you a special boutique exclusively for certified luxury pre-owned watches. This first-of-its-kind lounge displays the finest watches previously owned by collectors and aficionados alike, and brought back to their pristine original condition. The space offers you a chance to explore our selection of certified pre-owned luxury watches like never before.",
            font : EthosFont.Brother1816Regular(size: 12),
            alignment :  .left,
            foregroundColor : .black,
            lineHeightMultiple : 1.2,
            kern : 0.1
        )
    }
}
