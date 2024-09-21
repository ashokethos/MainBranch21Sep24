//
//  FindAStoreTableViewCell.swift
//  Ethos
//
//  Created by mac on 08/09/23.
//

import UIKit

class FindAStoreTableViewCell: UITableViewCell {

    @IBOutlet weak var viewTextFieldSearch: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var textFieldSearch: EthosTextField!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnTarget: UIButton!
    
    var delegate : SuperViewDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textFieldSearch.delegate = self
        self.viewTextFieldSearch.setBorder(borderWidth: 1, borderColor: .black, radius: 0)
        self.textFieldSearch.initWithUIParameters(placeHolderText: EthosConstants.SearchByACityStatePINCode, underLineColor: .clear)
    }
    
    @IBAction func btnLocationDidTapped(_ sender: UIButton) {
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.updateLocation])
        
    }
    
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.search, EthosKeys.value : textFieldSearch.text ?? ""])
    }
    
    
}

extension FindAStoreTableViewCell : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textFieldSearch.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.search, EthosKeys.value : self.textFieldSearch.text ?? ""])
    }
    
}
