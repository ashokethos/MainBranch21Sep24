//
//  DeletableTextCollectionViewCell.swift
//  Ethos
//
//  Created by mac on 19/09/23.
//

import UIKit

class DeletableTextCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var constraintHeight: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    
    var index : Int?
    var delegate : SuperViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewMain.setBorder(borderWidth: 1, borderColor: EthosColor.red, radius: constraintHeight.constant/2)
    }
    
    @IBAction func btnCrossDidTapped(_ sender: UIButton) {
        if let index = self.index {
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.delete, EthosKeys.value : self.lblTitle.text ?? "", EthosKeys.currentIndex : index])
        }
    }
}
