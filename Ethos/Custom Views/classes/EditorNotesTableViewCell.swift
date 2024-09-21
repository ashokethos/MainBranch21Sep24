//
//  EditorNotesTableViewCell.swift
//  Ethos
//
//  Created by Ashok kumar on 09/09/24.
//

import UIKit

class EditorNotesTableViewCell: UITableViewCell {

    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    var descriptionString : String? {
        didSet {
            if let callibreDescription = self.descriptionString {
                self.descriptionLbl.setAttributedTitleWithProperties(title: callibreDescription.htmlToAttributedString?.string ?? "", font: EthosFont.Brother1816Regular(size: 14), lineHeightMultiple: 1.25, kern: 0.5)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
