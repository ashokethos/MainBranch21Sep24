//
//  AboutCollectionTextDataTableViewCell.swift
//  Ethos
//
//  Created by Ashok kumar on 21/09/24.
//

import UIKit

class AboutCollectionTextDataTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var topConstraintTitleLbl: NSLayoutConstraint!
    @IBOutlet weak var topConstraintDescriptionLbl: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
