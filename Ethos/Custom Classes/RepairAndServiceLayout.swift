//
//  RepairAndServiceLayout.swift
//  Ethos
//
//  Created by mac on 19/01/24.
//

import UIKit

class RepairAndServiceLayout : UICollectionViewFlowLayout {
    override func prepare() {
        
        if self.collectionView?.tag == 0 {
            // .forShopping, .forPreowned
            minimumLineSpacing = 20
            let framewidth = collectionView?.frame.width ?? UIScreen.main.bounds.width
            let size = collectionView?.cellSize(noOfCellsInRow: 1.2, Height: 0) ?? CGSize.zero
            itemSize = CGSize(width: size.width, height: collectionView?.frame.height ?? 0)
        } else if self.collectionView?.tag == 1 {
            // .forDetails
            minimumLineSpacing = 0
            let size = collectionView?.cellSize(noOfCellsInRow: 1, Height: 0) ?? CGSize.zero
            itemSize = CGSize(width: size.width, height: collectionView?.frame.height ?? 0)
            
        } else if self.collectionView?.tag == 2  {
            // .forWhoWeAre
             minimumLineSpacing = 10
            let size = collectionView?.cellSize(noOfCellsInRow: 1, Height: 230)
            itemSize = CGSize(width: size?.width ?? 0, height: 230)
            
        } else if self.collectionView?.tag == 3 {
            // .forWhatWeDo
            minimumLineSpacing = 0
            itemSize = CGSize.zero
        } else if self.collectionView?.tag == 4 {
            // .forFromTheWatchGuide
            minimumLineSpacing = 20
            itemSize = CGSize(width: 317, height: 383)
            
        } else if self.collectionView?.tag == 5 {
            // .forsecondMovementSell
            minimumLineSpacing = 0
            itemSize = CGSize.zero
            
            
        } else if self.collectionView?.tag == 6 {
            //  .forsecondMovementTrade
            minimumLineSpacing = 0
            itemSize = CGSize.zero
            
            
        } else if self.collectionView?.tag == 7 {
            // forReapirAndServiceLocateUs
            minimumLineSpacing = 0
            itemSize = CGSize.zero
        }
        
        
        
       scrollDirection = .horizontal
        sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)

    }
    
    
}
