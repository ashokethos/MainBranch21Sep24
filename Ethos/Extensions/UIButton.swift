//
//  UIButton.swift
//  Ethos
//
//  Created by mac on 25/08/23.
//

import UIKit

extension UIButton {
    func setAttributedTitleWithProperties(
        title : String,
        font : UIFont,
        alignment : NSTextAlignment = .left,
        foregroundColor : UIColor = .black,
        backgroundColor : UIColor = .clear,
        lineHeightMultiple : CGFloat? = nil,
        kern : CGFloat = 0,
        showUnderline : Bool = false,
        underLineColor : UIColor = .black,
        underLineStyle : NSUnderlineStyle = .single
    ) {
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        
        if let lineHeightMultiple = lineHeightMultiple {
            let lineHeight = font.lineHeight
            let modifiedLineHeight = lineHeight*lineHeightMultiple
            let difference = modifiedLineHeight - lineHeight
            style.lineSpacing = difference
        }
        
        let attributes : [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : font,
            NSAttributedString.Key.paragraphStyle : style,
            NSAttributedString.Key.kern: kern,
            NSAttributedString.Key.foregroundColor : foregroundColor,
            NSAttributedString.Key.backgroundColor : backgroundColor
        ]
        
        
        
        let str = NSMutableAttributedString(string:title, attributes: attributes)
        
        if showUnderline {
            let textRange = NSRange(location: 0, length: str.length)
            str.addAttribute(NSAttributedString.Key.underlineColor, value: underLineColor.cgColor, range: textRange)
            str.addAttribute(NSAttributedString.Key.underlineStyle, value: underLineStyle.rawValue, range: textRange)
        }
        
        self.setAttributedTitle(str, for: .normal)
    }
}
