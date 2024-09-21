//
//  WhereToLocateUsTableViewCell.swift
//  Ethos
//
//  Created by mac on 22/09/23.
//

import UIKit
import SkeletonView
import Mixpanel

class WhereToLocateUsTableViewCell: UITableViewCell {
    
    var delegate : SuperViewDelegate?
    
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblSellWatch: UILabel!
    @IBOutlet weak var lblBuyWatch: UILabel!
    @IBOutlet weak var txtViewContactUs: UITextView!
    
    @IBOutlet weak var lblAddressHeading: UILabel!
    
    @IBOutlet weak var lblContactUsHeading: UILabel!
    
    
    var email1 = "contactus@secondmovement.com"
    var email2 = "stsm@secondmovement.com"
    var customerCareNumber = "+91 11426 10170"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateContacts()
        lblAddressHeading.setAttributedTitleWithProperties(title: "ADDRESS", font: EthosFont.Brother1816Medium(size: 12), alignment: .left, kern: 1)
        lblContactUsHeading.setAttributedTitleWithProperties(title: "CONTACT US", font: EthosFont.Brother1816Medium(size: 12), alignment: .left, kern: 1)
        self.txtViewContactUs.textContainerInset = .zero
        self.txtViewContactUs.textContainer.lineFragmentPadding = .zero
        
        txtViewContactUs.delegate = self
        txtViewContactUs.skeletonTextNumberOfLines = 3
        txtViewContactUs.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(18)
    }
    
    
    
    @IBAction func btnSellTapped(_ sender: Any) {
        let phoneNumber = lblSellWatch.text?.replacingOccurrences(of: " " , with:  "") ?? ""
        if let numberUrl = URL(string: "tel://\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(numberUrl) {
                UIApplication.shared.open(numberUrl)
            }
        }
    }
    
    @IBAction func btnBuyTapped(_ sender: Any) {
        let phoneNumber = lblBuyWatch.text?.replacingOccurrences(of: " " , with:  "") ?? ""
        if let numberUrl = URL(string: "tel://\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(numberUrl) {
                UIApplication.shared.open(numberUrl)
            }
        }
    }
    
    var contacts : [String : Any] = [:] {
        didSet {
            let site = Site.secondMovement
            if let data = self.contacts["data"] as? [String : Any], let items = data["items"] as? [[String : Any]] {
                
                for item in items {
                    if let label = item["lable"] as? String, let value = item[EthosConstants.value] as? String, let type = item["type"] as? String {
                        
                        var newValue = value
                        if type == "phone" || type == "whatsapp" {
                            newValue = value.filter(\.isWhitespace.negated)
                                .separate(every: 5, from: 3, with: " ")
                        }
                        
                        switch label {
                            
                        case "Email Address 1" :
                            if site == .secondMovement {
                                self.email1 = newValue
                            }
                            
                        case "Email Address 2" :
                            if site == .secondMovement {
                                self.email2 = newValue
                            }
                            
                        case "Customer Care number" :
                            if site == .secondMovement {
                                self.customerCareNumber = newValue
                            }
                            
                        case "To Buy A Watch" :
                            if site == .secondMovement {
                                self.lblBuyWatch.text = newValue
                            }
                            
                        case "To Sell A Watch" :
                            if site == .secondMovement {
                                self.lblSellWatch.text = newValue
                            }
                            
                        case "Service center address" :
                            if site == .secondMovement {
                                self.lblAddress.setAttributedTitleWithProperties(title: newValue, font: EthosFont.Brother1816Regular(size: 12), lineHeightMultiple: 1.5, kern: 0.1)
                            }
                            
                            
                        default : break
                            
                        }
                    }
                }
                
                self.updateContacts()
            }
        }
    }
    
    @IBAction func visitOurBoutiqueDidTapped(_ sender: UIButton) {
        Mixpanel.mainInstance().trackWithLogs(event: "Pre Owned Visit Boutique Clicked", properties: [
            EthosConstants.Email : Userpreference.email,
            EthosConstants.UID : Userpreference.userID,
            EthosConstants.Gender : Userpreference.gender,
            EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
            EthosConstants.Platform : EthosConstants.IOS
        ])
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.openWebPage, EthosKeys.url : EthosIdentifiers.mapUrl])
    }
    
    
    func updateContacts() {
        self.txtViewContactUs.setCustomerCareNumbers(customerCareNumber: self.customerCareNumber, email1: self.email1, email2: self.email2, lineHeightMultiple: 1.5, font: EthosFont.Brother1816Regular(size: 12))
    }
    
}

extension WhereToLocateUsTableViewCell : ContactUsViewModelDelegate {
    func didGetContacts(json: [String : Any], site: Site) {
        
    }
    
    func requestSuccess(message: String) {
        
    }
    
    func requestFailure(error: String) {
        
    }
    
    func startIndicator() {
        
    }
    
    func stopIndicator() {
        
    }
    
    
}

extension WhereToLocateUsTableViewCell : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.scheme == "tel" {
            
            if UIApplication.shared.canOpenURL(URL) {
                UIApplication.shared.open(URL)
            }
            
            return false
        }
        return true
    }
    
    
}
