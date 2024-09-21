//
//  Help&SupportCell.swift
//  Ethos
//
//  Created by mac on 07/08/23.
//

import UIKit

class HelpAndSupportCell: UITableViewCell {
    
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var imgViewIconBtn: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
}
