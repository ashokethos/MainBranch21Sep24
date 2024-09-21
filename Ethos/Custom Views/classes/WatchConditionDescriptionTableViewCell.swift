//
//  WatchConditionDescriptionTableViewCell.swift
//  Ethos
//
//  Created by mac on 14/12/23.
//

import UIKit

class WatchConditionDescriptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblAttribute: UILabel!
    
    @IBOutlet weak var lblValue: UILabel!
    
    @IBOutlet weak var viewTopSeperator: UIView!
    
    @IBOutlet weak var viewBottomSeperator: UIView!
    
    var data : (String , String)? {
        didSet {
            if let data = data {
                self.lblAttribute.text = data.0
                self.lblValue.text = data.1
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

   
    
}
