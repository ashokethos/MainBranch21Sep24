//
//  RevolutionReviewTableViewCell.swift
//  Ethos
//
//  Created by Ashok kumar on 31/07/24.
//

import UIKit

class RevolutionReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var backMainView: UIView!
    @IBOutlet weak var revolutionImg: UIImageView!
    @IBOutlet weak var reviewLbl: UILabel!
    @IBOutlet weak var reviewTitleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var heightBottomSpaceView: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setSpacing(height: CGFloat = 8, color : UIColor = EthosColor.appBGColor) {
        self.heightBottomSpaceView.constant = height
//        self.contentView.backgroundColor = color
        self.layoutIfNeeded()
    }
    
}

