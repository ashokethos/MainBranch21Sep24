//
//  RevolutionTableViewHeaderCell.swift
//  Ethos
//
//  Created by Ashok kumar on 31/07/24.
//

import UIKit

class RevolutionTableViewHeaderCell: UITableViewCell {

    @IBOutlet weak var viewAllBtn: UIButton!
    @IBOutlet weak var instagramBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var websiteLbl: UILabel!
    @IBOutlet weak var websiteBtn: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var instagramBtnLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        self.contentView.hideSkeleton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
