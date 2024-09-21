//
//  EthosBrandsLayout.swift
//  Ethos
//
//  Created by mac on 19/10/23.
//

import UIKit

class EthosBrandsLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        sectionInset = UIEdgeInsets.zero
        
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        
        itemSize = CGSize(width: ((self.collectionView?.frame.width ?? 0)/3) + 1, height: (((self.collectionView?.frame.width ?? 0) - 0.5)/3))
        
        scrollDirection = .horizontal
    }
}
