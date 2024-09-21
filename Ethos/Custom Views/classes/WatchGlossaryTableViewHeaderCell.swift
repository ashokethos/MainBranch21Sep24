//
//  WatchGlossaryTableViewHeaderCell.swift
//  Ethos
//
//  Created by mac on 2024-03-01.
//

import UIKit

class WatchGlossaryTableViewHeaderCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imageGlossary: UIImageView!
    @IBOutlet weak var collectionViewLetters: UICollectionView!
    @IBOutlet weak var lblSelectedLetter: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionViewLetters.registerCell(className: DiscoveryTabsCell.self)
        lblDescription.setAttributedTitleWithProperties(title: "Welcome to the Glossary section of \"The Watch guide\" Browse through to learn all the important terms associated with watchmaking and understand your timepiece better!", font: EthosFont.Brother1816Regular(size: 12), lineHeightMultiple: 1.25, kern: 0.5)
        setTitle(title: "Watch-Glossary".uppercased())
    }
    
    override func prepareForReuse() {
        self.contentView.hideSkeleton()
        self.collectionViewLetters.hideSkeleton()
    }
    
    func setTitle(title : String) {
        lblTitle.setAttributedTitleWithProperties(
            title: title,
            font: EthosFont.Brother1816Medium(size: 12),
            kern: 1
        )
    }
}
