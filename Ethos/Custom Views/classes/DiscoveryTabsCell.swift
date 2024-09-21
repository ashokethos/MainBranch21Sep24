//
//  DiscoveryTabsCell.swift
//  Ethos
//
//  Created by mac on 26/06/23.
//

import UIKit

class DiscoveryTabsCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewIndicator: UIView!
    @IBOutlet weak var constraintHeightIndicator: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        constraintHeightIndicator.constant = 2.5
        self.contentView.hideSkeleton()
    }

}
