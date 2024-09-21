//
//  SpecificationCollectionViewCell.swift
//  Ethos
//
//  Created by mac on 05/07/23.
//

import UIKit

class SpecificationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.isUserInteractionEnabled = true
        self.textView.isSelectable = true
        self.textView.isEditable = false
        self.textView.delaysContentTouches = false
        self.textView.isScrollEnabled = false
        self.textView.linkTextAttributes = [ NSAttributedString.Key.foregroundColor: EthosColor.red]
        self.textView.contentInsetAdjustmentBehavior = .never
        self.textView.textContainerInset = UIEdgeInsets.zero
        self.textView.layoutMargins = .zero
        self.textView.textContainer.lineFragmentPadding = 0;
    }
    
    var attribute : NSAttributedString? {
        didSet {
            if let attribute = self.attribute {
                self.textView.attributedText = attribute
            }
        }
    }
}
