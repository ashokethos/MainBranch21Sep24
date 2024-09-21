//
//  SpecificationTableViewCell.swift
//  Ethos
//
//  Created by mac on 04/07/23.
//

import UIKit

class SingleCollectionTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionViewSpecifications: UICollectionView!
    @IBOutlet weak var constraintLeadingCollectionView: NSLayoutConstraint!
    @IBOutlet weak var constraintTraillingCollectionView: NSLayoutConstraint!
    
    var currentTableView : EthosContentSizedTableView?
    
    var attributes = [NSAttributedString]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCells()
    }
    
    func setupCells() {
        collectionViewSpecifications.registerCell(className: SpecificationCollectionViewCell.self)
        collectionViewSpecifications.dataSource = self
        collectionViewSpecifications.delegate = self
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.currentTableView?.reloadData()
        }
    }
    
    
}

extension SingleCollectionTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attributes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: SpecificationCollectionViewCell.self), for: indexPath) as? SpecificationCollectionViewCell {
            cell.attribute = attributes[indexPath.item]
            return cell
        }
        return UICollectionViewCell()
    }
}
