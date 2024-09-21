//
//  EthosBulletTableViewCellForNumber.swift
//  Ethos
//
//  Created by mac on 18/08/23.
//

import UIKit

class EthosBulletTableViewCellForNumber: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imageBullet: UIImageView!
    @IBOutlet weak var lblBullet: UILabel!
    @IBOutlet weak var constraintLeadingTitle: NSLayoutConstraint!
    @IBOutlet weak var constraintImageBullet: NSLayoutConstraint!
    
    var index : Int? {
        didSet {
            if let index = index {
                self.lblBullet.text = ""
                self.imageBullet.image = UIImage(named: "bullet\(index)")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        self.lblBullet.text = ""
        self.imageBullet.image = UIImage.imageWithName(name: EthosConstants.bullet)
        self.contentView.backgroundColor = .white
    }
    
    var data : TitleDescriptionImageModel? {
        didSet {
            
            self.lblTitle.setAttributedTitleWithProperties(title: data?.title.uppercased() ?? "", font: EthosFont.Brother1816Medium(size: 10), kern: 0.5)
            self.lblDescription.text = data?.description ?? ""
            self.contentView.layoutIfNeeded()
        }
    }
}
