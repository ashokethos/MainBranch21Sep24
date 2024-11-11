//
//  UILabel.swift
//  Ethos
//
//  Created by mac on 31/07/23.
//

import Foundation
import UIKit

extension UILabel {
    
    func setAttributedTitleWithProperties(
        title : String,
        font : UIFont,
        alignment : NSTextAlignment = .left,
        foregroundColor : UIColor = .black,
        backgroundColor : UIColor = .clear,
        lineHeightMultiple : CGFloat? = nil,
        showUnderline : Bool = false,
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
            NSAttributedString.Key.backgroundColor : backgroundColor,
        ])
        
        if showUnderline == true {
            str.addAttributes([NSAttributedString.Key.underlineColor : foregroundColor, NSAttributedString.Key.underlineStyle : NSUnderlineStyle.thick.rawValue], range: NSRange(location: 0, length: str.length))
        }
        
        
        self.attributedText = str
    }
    
    func setHtmlTitleWithProperties(
            title: String,
            font: UIFont,
            alignment: NSTextAlignment = .left,
            foregroundColor: UIColor = .black,
            backgroundColor: UIColor = .clear,
            lineHeightMultiple: CGFloat? = nil,
            showUnderline: Bool = false,
            kern: CGFloat = 0
        ) {
            guard let data = title.data(using: .utf8),
                  let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) else { return }
            
            let style = NSMutableParagraphStyle()
            style.alignment = alignment
            
            if let lineHeightMultiple = lineHeightMultiple {
                let lineHeight = font.lineHeight
                let modifiedLineHeight = lineHeight*lineHeightMultiple
                let difference = modifiedLineHeight - lineHeight
                style.lineSpacing = difference
            }
            
            let str = NSMutableAttributedString(string: attributedString.string, attributes: [
                NSAttributedString.Key.font : font,
                NSAttributedString.Key.paragraphStyle : style,
                NSAttributedString.Key.kern: kern,
                NSAttributedString.Key.foregroundColor : foregroundColor,
                NSAttributedString.Key.backgroundColor : backgroundColor,
            ])
            
            if showUnderline == true {
                str.addAttributes([NSAttributedString.Key.underlineColor : foregroundColor, NSAttributedString.Key.underlineStyle : NSUnderlineStyle.thick.rawValue], range: NSRange(location: 0, length: str.length))
            }
            
            
            self.attributedText = str
        }
}
