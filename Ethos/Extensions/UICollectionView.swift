//
//  UIViewController.swift
//  Ethos
//
//  Created by mac on 26/06/23.
//

import UIKit

extension UICollectionView {
    func cellSize(noOfCellsInRow:Double, Height:CGFloat) -> CGSize {
        let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        let size = CGFloat((self.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: Height)
    }
    
    func registerCell(className : AnyClass) {
        self.register(UINib(nibName: String(describing: className.self), bundle: nil), forCellWithReuseIdentifier: String(describing: className.self))
    }
    
    func setEmptyMessage(_ message: String) {
        // Create and configure the UILabel for the empty message
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "Brother-1816-Medium", size: 14)
        
        // Add the UILabel to the collection view's background view
        let containerView = UIView(frame: self.bounds)
        containerView.addSubview(messageLabel)
        
        // Set constraints to center the message label within the container view
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16)
        ])
        
        self.backgroundView = containerView
    }
    
    func restore() {
        self.backgroundView = nil
    }

}
