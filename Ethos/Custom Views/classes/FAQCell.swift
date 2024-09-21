//
//  FAQCell.swift
//  Ethos
//
//  Created by mac on 27/06/23.
//

import UIKit
import SkeletonView

class FAQCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UITextView!
    @IBOutlet weak var constraintLeading: NSLayoutConstraint!
    @IBOutlet weak var viewSeperator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblTitle.skeletonTextNumberOfLines = 1
        self.lblDescription.skeletonTextNumberOfLines = 1
        self.lblTitle.skeletonLineSpacing = 10
        self.lblTitle.skeletonTextLineHeight = .fixed(10)
        self.lblDescription.skeletonTextLineHeight = .fixed(10)
        self.lblDescription.delegate = self
        self.lblDescription.isUserInteractionEnabled = true
        self.lblDescription.isSelectable = true
        self.lblDescription.isEditable = false
        self.lblDescription.delaysContentTouches = false
        self.lblDescription.isScrollEnabled = false
        self.lblDescription.textContainerInset = UIEdgeInsets.zero
        self.lblDescription.layoutMargins = .zero
        self.lblDescription.textContainer.lineFragmentPadding = 0;
        self.lblDescription.dataDetectorTypes = [.link, .phoneNumber]
        self.lblDescription.linkTextAttributes = [ NSAttributedString.Key.foregroundColor: EthosColor.red]
        self.lblDescription.contentInsetAdjustmentBehavior = .never
       
    }
    
    override func prepareForReuse() {
        self.contentView.hideSkeleton()
        self.lblTitle.attributedText = nil
        self.lblDescription.attributedText = nil
        self.lblTitle.text = nil
        self.lblDescription.text = nil
    }
    
    var faq : FAQ? {
        didSet {
            if let faq = self.faq {
                
                self.lblTitle.setAttributedTitleWithProperties(title: faq.question ?? "", font: EthosFont.Brother1816Medium(size: 12),foregroundColor: .black, kern: 0.1)
                
                self.lblDescription.setAttributedTitleWithProperties(title: faq.answer ?? "", font: EthosFont.Brother1816Medium(size: 12),foregroundColor: EthosColor.darkGrey, kern: 0.1)
                
            }
        }
    }
}

extension FAQCell : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.scheme == "tel" {
            if UIApplication.shared.canOpenURL(URL) {
                UIApplication.shared.open(URL)
            }
            return false
        } else {
            UserActivityViewModel().getDataFromActivityUrl(url: URL.absoluteString)
        }
        return false
    }
}
