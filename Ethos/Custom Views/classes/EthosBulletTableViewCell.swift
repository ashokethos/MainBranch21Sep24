//
//  EthosBulletTableViewCell.swift
//  Ethos
//
//  Created by mac on 18/08/23.
//

import UIKit

class EthosBulletTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imageBullet: UIImageView!
    @IBOutlet weak var btnBullet: UIButton!
    @IBOutlet weak var constraintLeadingTitle: NSLayoutConstraint!
    @IBOutlet weak var constraintImageBullet: NSLayoutConstraint!
    
    var index : Int? {
        didSet {
            self.btnBullet.setTitle( (index != nil) ? String(index ?? 1) : "" , for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        self.btnBullet.setTitle("", for: .normal)
        self.imageBullet.image = UIImage.imageWithName(name: EthosConstants.bullet)
        self.contentView.backgroundColor = .white
    }
    
    var data : TitleDescriptionImageModel? {
        didSet {
            
            self.lblTitle.setAttributedTitleWithProperties(title: data?.title.uppercased() ?? "", font: EthosFont.Brother1816Medium(size: 10), kern: 0.5)
            
            
            self.lblDescription.text = data?.description ?? ""
            if data?.image != nil && data?.image != ""  {
                self.imageBullet.image = UIImage.imageWithName(name: data?.image ?? "")
                self.btnBullet.setTitle("", for: .normal)
            }
            
            self.contentView.layoutIfNeeded()
        }
    }
}
