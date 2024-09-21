//
//  CustomSizedCollectionView.swift
//  Ethos
//
//  Created by SoftGrid on 11/07/23.
//

import UIKit

final class EthosContentSizedCollectionView: UICollectionView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
