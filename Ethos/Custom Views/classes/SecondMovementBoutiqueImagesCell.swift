//
//  SecondMovementBoutiqueImagesCell.swift
//  Ethos
//
//  Created by mac on 29/11/23.
//

import UIKit

class SecondMovementBoutiqueImagesCell: UITableViewCell {

    @IBOutlet weak var imageViewStore: UIImageView!
    
    @IBOutlet weak var btnImage_I: UIButton!
    @IBOutlet weak var btnImage_II: UIButton!
    @IBOutlet weak var btnImage_III: UIButton!
    @IBOutlet weak var btnImage_IV: UIButton!
    @IBOutlet weak var btnImage_V: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func BtnImageDidTapped(_ sender: UIButton) {
        imageViewStore.image = sender.currentImage
        self.contentView.layoutIfNeeded()
    }
    
}
