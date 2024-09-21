//
//  UITableView.swift
//  Ethos
//
//  Created by SoftGrid on 13/07/23.
//

import Foundation
import UIKit

extension UITableView {
    func registerCell(className: AnyClass) {
        self.register(UINib(nibName: String(describing: className.self) , bundle: nil), forCellReuseIdentifier: String(describing: className.self))
    }
    
    func setEmptyMessage(_ message: String) {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            messageLabel.text = message
            messageLabel.textColor = .black
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont(name: "Brother-1816-Medium", size: 14)
            messageLabel.sizeToFit()

            self.backgroundView = messageLabel
            self.separatorStyle = .none
        }
    
    func setEmptyMessageTitleWithDes(_ message: String) {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
//            messageLabel.text = message
            messageLabel.textColor = .black
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
//            messageLabel.font = UIFont(name: "Brother-1816-Medium", size: 14)
            messageLabel.sizeToFit()
        let messageStr = message.components(separatedBy: "\n")
        guard messageStr.count == 2 else { return }
        let firstPart = "\(messageStr[0]) \n"
        let secondPart = messageStr[1]
        let attrsBold = [NSAttributedString.Key.font : UIFont(name: "Brother-1816-Medium", size: 14)]
        let attrsRegular = [NSAttributedString.Key.font : UIFont(name: "Brother-1816-Regular", size: 14)]
        let attributedString = NSMutableAttributedString(string:firstPart, attributes:attrsBold as [NSAttributedString.Key : Any])
        let normalString = NSMutableAttributedString(string:secondPart, attributes:attrsRegular as [NSAttributedString.Key : Any])
        attributedString.append(normalString)
        messageLabel.attributedText = attributedString
            self.backgroundView = messageLabel
            self.separatorStyle = .none
        }

        func restore() {
            self.backgroundView = nil
//            self.separatorStyle = .singleLine
        }
}
