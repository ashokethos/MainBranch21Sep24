//
//  TnCViewController.swift
//  Ethos
//
//  Created by mac on 31/07/23.
//

import UIKit
import Mixpanel

class DoccumentViewController: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
    }
    
    func setup() {
        self.addTapGestureToDissmissKeyBoard()
        self.titleLabel.text = self.title
    }

    @IBAction func btnBackDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
