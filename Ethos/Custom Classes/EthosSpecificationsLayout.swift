//
//  EthosSpecificationsLayout.swift
//  Ethos
//
//  Created by mac on 08/01/24.
//

import Foundation
import UIKit

class EthosSpecificationsLayout: UICollectionViewFlowLayout {
    override func prepare() {
        scrollDirection = .vertical
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let size = collectionView?.cellSize(noOfCellsInRow: 2, Height: 30) ?? CGSize.zero
        itemSize = CGSize(width: size.width, height: 70)
    }
    
    
}
