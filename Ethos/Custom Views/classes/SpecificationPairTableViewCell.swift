//
//  SpecificationPairTableViewCell.swift
//  Ethos
//
//  Created by mac on 2024-03-14.
//

import UIKit
import SkeletonView

class SpecificationPairTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var textView1: UITextView!
    @IBOutlet weak var textView2: UITextView!
    
    @IBOutlet weak var textView3: UITextView!
    @IBOutlet weak var textView4: UITextView!
    
    var indexPath : IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUIForTextView(textview: self.textView1)
        setUIForTextView(textview: self.textView2)
        setUIForTextView(textview: self.textView3)
        setUIForTextView(textview: self.textView4)
        
        self.textView1.skeletonTextNumberOfLines = 1
        self.textView2.skeletonTextNumberOfLines = 1
        self.textView3.skeletonTextNumberOfLines = 1
        self.textView4.skeletonTextNumberOfLines = 1
        
        self.textView1.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
        self.textView2.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
        self.textView3.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
        self.textView4.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
    }
    
    func setUIForTextView(textview : UITextView) {
        textview.isUserInteractionEnabled = true
        textview.isSelectable = true
        textview.isEditable = false
        textview.delaysContentTouches = false
        textview.isScrollEnabled = false
        textview.linkTextAttributes = [ NSAttributedString.Key.foregroundColor: EthosColor.red]
        textview.contentInsetAdjustmentBehavior = .never
        textview.textContainerInset = UIEdgeInsets.zero
        textview.layoutMargins = .zero
        textview.textContainer.lineFragmentPadding = 0;
    }
    
    override func prepareForReuse() {
        self.contentView.hideSkeleton()
        self.textView1.attributedText = nil
        self.textView2.attributedText = nil
        self.layoutIfNeeded()
    }

    var attribute : (NSAttributedString?, NSAttributedString?, NSAttributedString?, NSAttributedString?)? {
        didSet {
            if let text = attribute?.0 {
                self.textView1.attributedText = text
            } else {
                self.textView1.attributedText = nil
            }
            
            if let text = attribute?.1 {
                self.textView2.attributedText = text
            } else {
                self.textView2.attributedText = nil
            }
            
            if let text = attribute?.2 {
                self.textView3.attributedText = text
            } else {
                self.textView3.attributedText = nil
            }
            
            if let text = attribute?.3 {
                self.textView4.attributedText = text
            } else {
                self.textView4.attributedText = nil
            }
            
           
            self.layoutIfNeeded()
        }
    }
    
    
    
}
