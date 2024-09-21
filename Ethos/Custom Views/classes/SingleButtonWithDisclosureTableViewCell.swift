//
//  SingleButtonWithDisclosureTableViewCell.swift
//  Ethos
//
//  Created by mac on 13/10/23.
//

import UIKit

class SingleButtonWithDisclosureTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var txtBtn: UIButton!
    @IBOutlet weak var btnDisClosure: UIButton!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var viewButton: UIView!
    @IBOutlet weak var constraintLeading: NSLayoutConstraint!
    
    @IBOutlet weak var constraintTopSpacing: NSLayoutConstraint!
    
    @IBOutlet weak var constraintBottomSpacing: NSLayoutConstraint!
    
    @IBOutlet weak var constraintSpacingBtnTitle: NSLayoutConstraint!
    
    var action : () -> () = {
        
    }
    
    var delegate : SuperViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.txtBtn.setAttributedTitleWithProperties(title: EthosConstants.GetAQuote.uppercased(), font: EthosFont.Brother1816Regular(size: 12),foregroundColor: .black ,kern: 0.5)
    }
    
    override func prepareForReuse() {
        self.btn.isUserInteractionEnabled = true
        self.txtBtn.isUserInteractionEnabled = true
        self.btnDisClosure.isUserInteractionEnabled = true
        self.constraintBottomSpacing.constant = 0
        self.constraintTopSpacing.constant = 0
    }

  
    @IBAction func btnAction(_ sender: Any) {
        self.action()
    }
    
}
