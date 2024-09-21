//
//  EthosLayout.swift
//  Ethos
//
//  Created by mac on 04/08/23.
//

import Foundation
import UIKit

class EthosProductLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
      sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
      minimumLineSpacing = 0
      minimumInteritemSpacing = 20
      scrollDirection = .vertical
        itemSize = collectionView?.cellSize(noOfCellsInRow: 2, Height: 346) ?? CGSize.zero
        
    }
    

}
