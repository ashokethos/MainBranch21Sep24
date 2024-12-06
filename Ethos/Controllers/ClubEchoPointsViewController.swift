//
//  ClubEchoPointsViewController.swift
//  Ethos
//
//  Created by Ashok kumar on 28/10/24.
//

import UIKit

class ClubEchoPointsViewController: UIViewController {
    
    var points = 0
    @IBOutlet weak var btnStartShopping: UIButton!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnStartShopping.setAttributedTitleWithProperties(title: "Start Shopping".uppercased(), font: EthosFont.Brother1816Bold(size: 10), foregroundColor: .white, lineHeightMultiple: 1.6, kern: 0.5)
        self.lblTitle.setAttributedTitleWithProperties(title: "CLUB ECHO POINTS", font: EthosFont.Brother1816Bold(size: 10), alignment: .center, foregroundColor: .white,  kern: 0.5)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            if self.points > 0 {
                let attributedClubEchoPoint = NSMutableAttributedString(string: "You have", attributes: [NSAttributedString.Key.font : EthosFont.MrsEavesXLSerifNarOTReg(size: 18), NSAttributedString.Key.foregroundColor : EthosColor.blackColor])
                let attributedClubEchoPointValue = NSMutableAttributedString(string: " \(self.points.getCommaSeperatedStringValue() ?? "0") ", attributes: [NSAttributedString.Key.font : EthosFont.MrsEavesXLSerifNarOTBold(size: 18), NSAttributedString.Key.foregroundColor : EthosColor.blackColor])
                let attributedClubEchoPointText = NSMutableAttributedString(string: "Club Echo Points. Keep shopping with Ethos Watches to accumulate more points.", attributes: [NSAttributedString.Key.font : EthosFont.MrsEavesXLSerifNarOTReg(size: 18), NSAttributedString.Key.foregroundColor : EthosColor.blackColor])
                attributedClubEchoPoint.append(attributedClubEchoPointValue)
                attributedClubEchoPoint.append(attributedClubEchoPointText)
                self.lblDescription.attributedText = attributedClubEchoPoint
//                self.lblDescription.setAttributedTitleWithProperties(title: "You have \(self.points.getCommaSeperatedStringValue() ?? "0") Club Echo Points. Keep shopping with Ethos Watches to accumulate more points.",  font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18), alignment: .center,  lineHeightMultiple: 1.33)
            } else {
                self.lblDescription.setAttributedTitleWithProperties(title: "You have not any Club Echo Points. Keep shopping with Ethos Watches to accumulate the points.",  font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18), alignment: .center,  lineHeightMultiple: 1.33)
            }
        }
    }
    
    @IBAction func btnBackDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
//        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchNewViewController.self)) as? SearchNewViewController {
            vc.isForPreOwned = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnStartShoppingDidTapped(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        DispatchQueue.main.async {
            UIApplication.topViewController()?.tabBarController?.selectedIndex = 2
            UIApplication.topViewController()?.navigationController?.popToRootViewController(animated: true)
        }
    }
}
