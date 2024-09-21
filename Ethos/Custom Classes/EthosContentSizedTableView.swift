//
//  EthosContentSizedTableView.swift
//  Ethos
//
//  Created by mac on 27/06/23.
//

import Foundation

import UIKit

final class EthosContentSizedTableView: UITableView {
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
