//
//  EthosAlertController.swift
//  Ethos
//
//  Created by mac on 02/08/23.
//

import UIKit

class EthosAlertController: UIViewController {

    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var viewGrey: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var stackViewButtons: UIStackView!
    @IBOutlet weak var btnFirstAction: UIButton!
    @IBOutlet weak var btnSecondAction: UIButton!
    @IBOutlet weak var widthCostraintFirstAction: NSLayoutConstraint!
    @IBOutlet weak var widthConstraintSecondAction: NSLayoutConstraint!
    @IBOutlet weak var constraintVerticalpacingTitleAndMessage: NSLayoutConstraint!
    var firstButtonAction : (()->())?
    var secondButtonAction : (()->())?
    var firstActionTitle : String? = nil
    var secondActionTitle : String? = nil
    var mainTitle  = ""
    var mainMessage = ""
    
    @IBOutlet weak var btnTransparentBackGround: UIButton!
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        self.view.backgroundColor = .clear
    }
    
    func setup() {
        self.addTapGestureToDissmissKeyBoard()
        self.btnFirstAction.setBorder(borderWidth: 1, borderColor: .black, radius: 0)
        self.btnSecondAction.setBorder(borderWidth: 1, borderColor: .black, radius: 0)
        self.viewAlert.layer.masksToBounds = true
        self.viewAlert.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.viewAlert.layer.cornerRadius = 32
        
        if mainTitle == "" || mainMessage == ""  {
            constraintVerticalpacingTitleAndMessage.constant = 0
        } else {
            constraintVerticalpacingTitleAndMessage.constant = 40
        }
        
        if firstActionTitle == nil {
            self.btnFirstAction.isHidden = true
        } else {
            self.btnFirstAction.setAttributedTitleWithProperties(title: firstActionTitle?.uppercased() ?? "", font: EthosFont.Brother1816Regular(size: 12), foregroundColor: .black, backgroundColor: .white, lineHeightMultiple: 1.5, kern: 1)
        }
        if secondActionTitle == nil {
            self.btnSecondAction.isHidden = true
        }  else {
            self.btnSecondAction.setAttributedTitleWithProperties(title: secondActionTitle?.uppercased() ?? "", font: EthosFont.Brother1816Regular(size: 12), foregroundColor: .white, backgroundColor: .black, lineHeightMultiple: 1.5, kern: 1)
        }
        self.lblTitle.text = self.mainTitle
        self.lblMessage.text = self.mainMessage
        self.view.layoutIfNeeded()
    }
    
    func setActions(title : String = "", message: String = "", firstActionTitle : String? = nil, secondActionTitle : String? = nil, firstAction : @escaping ()->() = {}, secondAction : @escaping()->() = {}) {
        self.mainTitle = title
        self.mainMessage = message
        self.firstActionTitle = firstActionTitle
        self.secondActionTitle = secondActionTitle
        self.firstButtonAction = firstAction
        self.secondButtonAction = secondAction
    }
    
    @IBAction func firstButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true){
            (self.firstButtonAction ?? {})()
        }
    }
    
    @IBAction func secondButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true){
            (self.secondButtonAction ?? {})()
        }
    }
    
    @IBAction func swipeDown(_ sender: UISwipeGestureRecognizer) {
        self.dismiss(animated: true)
        
    }
    
    @IBAction func btnTransparentBackGroundDidTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
