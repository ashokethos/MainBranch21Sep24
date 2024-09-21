//
//  SpacingTableViewCell.swift
//  Ethos
//
//  Created by mac on 21/08/23.
//

import UIKit

class SpacingTableViewCell: UITableViewCell {

    @IBOutlet weak var constraintHeight: NSLayoutConstraint!
    
    func setSpacing(height: CGFloat = 8, color : UIColor = EthosColor.appBGColor) {
        self.constraintHeight.constant = height
        self.contentView.backgroundColor = color
        self.layoutIfNeeded()
    }
    
}
