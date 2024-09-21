//
//  RepairAndDemoContactsCell.swift
//  Ethos
//
//  Created by mac on 17/08/23.
//

import UIKit

class RepairAndServiceContactsCell: UITableViewCell {
    
    @IBOutlet weak var viewBtnKnowMore: UIView!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblServiceCenterAddress: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblPhoneNumber1: UILabel!
    @IBOutlet weak var lblPhoneNumber2: UILabel!
    @IBOutlet weak var btnKnowMoreDisclosure: UIButton!
    @IBOutlet weak var txtBtnKnowMore: UIButton!
    
    var delegate : SuperViewDelegate?
    
    var viewModel = ContactUsViewModel()
    
    override func awakeFromNib() {
        viewModel.delegate = self
        self.txtBtnKnowMore.setAttributedTitleWithProperties(title: EthosConstants.KnowMore.uppercased(), font: EthosFont.Brother1816Regular(size: 10), kern: 0.5)
    }
    
    func callApi(forSecondMovement : Bool) {
        self.viewModel.getContacts(site: forSecondMovement ? .secondMovement : .ethos, completion: {
            json in
        })
    }
    
    @IBAction func btnVisitOurBoutiqueTapped(_ sender: UIButton) {
        if let url = URL(string: EthosIdentifiers.mapUrl), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func btnKnowMoreDidTapped(_ sender: UIButton) {
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.route, EthosKeys.value : String(describing: HelpAndSupportViewController.self)])
        
    }
    
    @IBAction func callUs1Tapped(_ sender: UIButton) {
        let phoneNumber = lblPhoneNumber1.text?.replacingOccurrences(of: " " , with:  "") ?? ""
        if let numberUrl = URL(string: "tel://\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(numberUrl) {
                UIApplication.shared.open(numberUrl)
            }
        }
    }
    
    @IBAction func callUs2Tapped(_ sender: UIButton) {
        let phoneNumber = lblPhoneNumber2.text?.replacingOccurrences(of: " " , with:  "") ?? ""
        if let numberUrl = URL(string: "tel://\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(numberUrl) {
                UIApplication.shared.open(numberUrl)
            }
        }
    }
    
    @IBAction func emailUsTapped(_ sender: UIButton) {
        let phoneNumber = lblEmail.text?.replacingOccurrences(of: " " , with:  "") ?? ""
        if let numberUrl = URL(string: "mailto:\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(numberUrl) {
                UIApplication.shared.open(numberUrl)
            }
        }
    }
    
    
}

extension RepairAndServiceContactsCell : ContactUsViewModelDelegate {
    func requestSuccess(message: String) {
        
    }
    
    func requestFailure(error: String) {
        
    }
    
    func startIndicator() {
        
    }
    
    func stopIndicator() {
        
    }
    
    func didGetContacts(json: [String : Any], site: Site) {
        DispatchQueue.main.async {
            if let data = json["data"] as? [String : Any], let items = data["items"] as? [[String : Any]] {
                
                for item in items {
                    if let label = item["lable"] as? String, let value = item[EthosConstants.value] as? String, let type = item["type"] as? String {
                        
                        var newValue = value
                        if type == "phone" || type == "whatsapp" {
                            newValue = value.filter(\.isWhitespace.negated)
                                .separate(every: 5, from: 3, with: " ")
                        }
                        
                        switch label {
                          
                        case "Luxery Watch HelpLIne 1" :
                            if site == .ethos {
                                self.lblPhoneNumber1.text = newValue
                            }
                            
                        case "Luxery Watch HelpLIne 2" :
                            if site == .ethos {
                                self.lblPhoneNumber2.text = newValue
                            }
                            
                        case "Service center address" :
                           
                                self.lblServiceCenterAddress.text = newValue
                           
                            
                            
                        case "Email Address 1" :
                            if site == .secondMovement {
                                self.lblEmail.text = newValue
                            }
                            
                        case "Email Us" :
                            if site == .ethos {
                                self.lblEmail.text = newValue
                            }
                            
                        case "Customer Care number" :
                            if site == .secondMovement {
                                self.lblPhoneNumber1.text = newValue
                            }
                            
                        case "To Buy A Watch" :
                            if site == .secondMovement {
                                self.lblPhoneNumber2.text = newValue
                            }
                            
                            
                        default : break
                            
                        }
                    }
                }
            }
        }
    }
    
    
}
