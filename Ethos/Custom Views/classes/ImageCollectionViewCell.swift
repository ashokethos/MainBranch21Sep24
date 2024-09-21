//
//  ImageCollectionViewCell.swift
//  Ethos
//
//  Created by mac on 28/06/23.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainImage: UIImageView!
   
    @IBOutlet weak var btnCross: UIButton!
    
    var index = 0
    var delegate : SuperViewDelegate?
    var brand : BrandModel? {
        didSet {
            if let imageOfBrand = brand?.image, let url = URL(string: imageOfBrand) {
                self.mainImage.kf.setImage(with: url)
            }
        }
    }
    
    override func prepareForReuse() {
        self.contentView.setBorder(borderWidth: 0, borderColor: .clear, radius: 0)
        self.btnCross.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.btnCross.isHidden = true
    }
    
    
    @IBAction func btnCrossDidTapped(_ sender: UIButton) {
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.removeImage, EthosKeys.value : self.index])
    }
    
}
