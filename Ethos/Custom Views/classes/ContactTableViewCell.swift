//
//  ContactTableViewCell.swift
//  Ethos
//
//  Created by mac on 10/08/23.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lwh1: UIButton!
    @IBOutlet weak var lwh2: UIButton!
    @IBOutlet weak var ooh1: UIButton!
    @IBOutlet weak var ooh2: UIButton!
    @IBOutlet weak var gq: UIButton!
    @IBOutlet weak var wa: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    let viewModel = ContactUsViewModel()
    
    override func awakeFromNib() {
        viewModel.delegate = self
        callApi()
    }
    
    func callApi() {
        viewModel.getContacts( completion: {
            json in
        })
    }
    
}

extension ContactTableViewCell : ContactUsViewModelDelegate {
    func didGetContacts(json: [String : Any], site: Site) {
        print(json)
    }
    
    func requestSuccess(message: String) {
        
    }
    
    func requestFailure(error: String) {
        
    }
    
    func startIndicator() {
        DispatchQueue.main.async {
            self.indicator.startAnimating()
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
        }
    }
    
}
