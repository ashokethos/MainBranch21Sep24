//
//  EthosFeaturedVideoCollectionLayout.swift
//  Ethos
//
//  Created by mac on 29/12/23.
//

import UIKit

class EthosFeaturedVideoCollectionLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
      sectionInset = UIEdgeInsets.zero
        
       minimumLineSpacing = 0
       minimumInteritemSpacing = 0
        
        if let width = collectionView?.frame.width, 
            let height = collectionView?.frame.height {
            itemSize = CGSize(width: width , height: height )
        }
        scrollDirection = .horizontal
    }
}

