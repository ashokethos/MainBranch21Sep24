//
//  UITextView.swift
//  Ethos
//
//  Created by mac on 10/08/23.
//

import UIKit

extension UITextView  {
    func setTermsAndConditionMessage(forSignIn : Bool) {
        self.contentInsetAdjustmentBehavior = .never
        self.textContainerInset = UIEdgeInsets.zero
        self.layoutMargins = .zero
        textContainer.lineFragmentPadding = 0;
        
        let str = NSMutableAttributedString(string: forSignIn ? EthosConstants.termsAndConditionsTextForSignIn : EthosConstants.termsAndConditionsTextForSignUp, attributes: [NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 12)])
        
        str.addAttributes([.foregroundColor : EthosColor.red, .link : EthosIdentifiers.termsURI, .font : EthosFont.Brother1816Regular(size: 12)], range: (str.string as NSString).range(of: EthosConstants.TermsOfUse))
        
        str.addAttributes([.foregroundColor : EthosColor.red,  .link : EthosIdentifiers.privacyPolicyURI,  .font : EthosFont.Brother1816Regular(size: 12)], range: (str.string as NSString).range(of: EthosConstants.PrivacyPolicy))
        
        self.linkTextAttributes = [ NSAttributedString.Key.foregroundColor: EthosColor.red]
        self.attributedText = str
        self.isUserInteractionEnabled = true
        self.isSelectable = true
        self.isEditable = false
        self.delaysContentTouches = false
        self.isScrollEnabled = false
    }
    
    func setCustomerCareNumbers(customerCareNumber : String, email1 : String, email2 : String, lineHeightMultiple : CGFloat? = nil, font : UIFont) {
        self.contentInsetAdjustmentBehavior = .never
        self.textContainerInset = UIEdgeInsets.zero
        self.layoutMargins = .zero
        textContainer.lineFragmentPadding = 0;
        
        let str = NSMutableAttributedString(string: customerCareNumber + "\n" + email1 + "\n" + email2, attributes: [NSAttributedString.Key.font : font])
        
        str.addAttributes([.foregroundColor : UIColor.black, .link : customerCareNumber.phoneNumberUrl, .font : font], range: (str.string as NSString).range(of: customerCareNumber))
        
        str.addAttributes([.foregroundColor : UIColor.black,  .link : email1.emailUrl,  .font : font], range: (str.string as NSString).range(of: email1))
        
        str.addAttributes([.foregroundColor : UIColor.black,  .link : email2.emailUrl,  .font : font], range: (str.string as NSString).range(of: email2))
        
        self.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        
        if let lineHeightMultiple = lineHeightMultiple {
            let lineHeight = font.lineHeight
            let modifiedLineHeight = lineHeight*lineHeightMultiple
            let difference = modifiedLineHeight - lineHeight
            style.lineSpacing = difference
            str.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: (str.string as NSString).range(of: str.string))
        }
        
        str.addAttribute(NSAttributedString.Key.kern, value: 0.1, range: (str.string as NSString).range(of: str.string))
        
        self.attributedText = str
        self.isUserInteractionEnabled = true
        self.isSelectable = true
        self.isEditable = false
        self.delaysContentTouches = false
        self.isScrollEnabled = false
    }
    
    func setAttributedTitleWithProperties(
        title : String,
        font : UIFont,
        alignment : NSTextAlignment = .left,
        foregroundColor : UIColor = .black,
        backgroundColor : UIColor = .clear,
        lineHeightMultiple : CGFloat? = nil,
        kern : CGFloat = 0
    ) {
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        
        if let lineHeightMultiple = lineHeightMultiple {
            let lineHeight = font.lineHeight
            let modifiedLineHeight = lineHeight*lineHeightMultiple
            let difference = modifiedLineHeight - lineHeight
            style.lineSpacing = difference
        }
        
        let str = NSMutableAttributedString(string:title, attributes: [
            NSAttributedString.Key.font : font,
            NSAttributedString.Key.paragraphStyle : style,
            NSAttributedString.Key.kern: kern,
            NSAttributedString.Key.foregroundColor : foregroundColor,
            NSAttributedString.Key.backgroundColor : backgroundColor
        ])
        
        self.attributedText = str
    }
}
