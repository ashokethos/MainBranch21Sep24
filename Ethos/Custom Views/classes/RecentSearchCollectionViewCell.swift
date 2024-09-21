//
//  RecentSearchCollectionViewCell.swift
//  Ethos
//
//  Created by Ashok kumar on 12/07/24.
//

import UIKit

class RecentSearchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = 5.0
        backView.layer.masksToBounds = true
        self.titleLbl.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.titleLbl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}
