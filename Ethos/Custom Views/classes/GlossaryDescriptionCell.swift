//
//  GlossaryDescriptionCell.swift
//  Ethos
//
//  Created by mac on 27/06/23.
//

import UIKit
import Mixpanel

class GlossaryDescriptionCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var constraintLeading: NSLayoutConstraint!
    @IBOutlet weak var viewSeperator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        self.contentView.hideSkeleton()
    }
    
    var element : Glossary? {
        didSet {
            
            let title = element?.title?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "&nbsp;", with: "").replacingOccurrences(of: "<i>", with: "").replacingOccurrences(of: "</i>", with: "") ?? ""
            
            self.lblTitle.setAttributedTitleWithProperties(title: title, font: EthosFont.Brother1816Medium(size: 12), kern: 0.5)
            
            let content = element?.content?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "&nbsp;", with: "").replacingOccurrences(of: "<i>", with: "").replacingOccurrences(of: "</i>", with: "") ?? ""
            
            self.lblDescription.setAttributedTitleWithProperties(title: content.trimmingCharacters(in: .whitespacesAndNewlines), font: EthosFont.Brother1816Regular(size: 12), lineHeightMultiple: 1.25, kern: 0.5)
            
            if element?.isExpanded ?? false {
                self.lblDescription.numberOfLines = 0
            } else {
                self.lblDescription.numberOfLines = 3
            }
            
            self.lblDescription.lineBreakMode = .byTruncatingTail
            
            self.contentView.layoutIfNeeded()
        }
    }
}
