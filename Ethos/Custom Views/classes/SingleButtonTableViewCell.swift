//
//  SingleButtonTableViewCell.swift
//  Ethos
//
//  Created by mac on 2024-03-01.
//

import UIKit

class SingleButtonTableViewCell: UITableViewCell {

    
    @IBOutlet weak var btnMain: UIButton!
    
    var action : () -> () = {
        
    }
    
    var delegate : SuperViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnMain.setAttributedTitleWithProperties(title: EthosConstants.ViewAll.uppercased(), font: EthosFont.Brother1816Medium(size: 12), kern: 0.5)
        btnMain.setBorder(borderWidth: 1, borderColor: .black, radius: 0)
    }
    
    override func prepareForReuse() {
        self.contentView.hideSkeleton()
    }
    
    @IBAction func btnMainAction(_ sender: UIButton) {
        action()
    }
}
