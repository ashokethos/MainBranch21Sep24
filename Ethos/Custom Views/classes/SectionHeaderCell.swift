//
//  SectionHeaderCell.swift
//  Ethos
//
//  Created by mac on 15/12/23.
//

import UIKit

class SectionHeaderCell: UITableViewCell {

    @IBOutlet weak var lblHeader: UILabel!
    
    @IBOutlet weak var viewBottom: UIView!
    
    @IBOutlet weak var btnDisclosure: UIButton!
    
    @IBOutlet weak var btnViewAll: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.btnViewAll.isHidden = true
        self.btnDisclosure.isHidden = true
    }

    override func prepareForReuse() {
        self.btnViewAll.isHidden = true
        self.btnDisclosure.isHidden = true
    }
    
    func setTitle(title : String) {
        lblHeader.setAttributedTitleWithProperties(
            title: title,
            font: EthosFont.Brother1816Medium(size: 12),
            kern: 1
        )
    }
    
    @IBAction func btnViewAllDidTapped(_ sender: UIButton) {
        
    }
    
    
}
