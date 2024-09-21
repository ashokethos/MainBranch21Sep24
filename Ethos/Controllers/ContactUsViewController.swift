//
//  ContactUsViewController.swift
//  Ethos
//
//  Created by mac on 07/08/23.
//

import UIKit
import Mixpanel

class ContactUsViewController: UIViewController {
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var txtFieldName: EthosTextField!
    @IBOutlet weak var txtFieldEmail: EthosTextField!
    @IBOutlet weak var txtFieldPhoneNumber: EthosTextField!
    @IBOutlet weak var txtFieldCity: EthosTextField!
    @IBOutlet weak var txtFieldSubject: EthosTextField!
    @IBOutlet weak var viewName: UIView!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewPhoneNumber: UIView!
    @IBOutlet weak var viewCity: UIView!
    @IBOutlet weak var viewSubject: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var lwh1: UIButton!
    @IBOutlet weak var lwh2: UIButton!
    @IBOutlet weak var ooh1: UIButton!
    @IBOutlet weak var ooh2: UIButton!
    @IBOutlet weak var ccn1: UIButton!
    @IBOutlet weak var email: UIButton!
    @IBOutlet weak var smBuyWatch: UIButton!
    @IBOutlet weak var smSellWatch: UIButton!
    @IBOutlet weak var smGQ: UIButton!
    @IBOutlet weak var smWA: UIButton!
    @IBOutlet weak var txtFieldMessage: EthosTextField!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var lblTitle1: UILabel!
    @IBOutlet weak var lblTitle2: UILabel!
    
    var viewModel = ContactUsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setTextFields()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        self.setTextFields()
    }
    
    func setup() {
        self.txtFieldName.delegate = self
        self.txtFieldEmail.delegate = self
        self.txtFieldPhoneNumber.delegate = self
        self.txtFieldCity.delegate = self
        self.txtFieldMessage.delegate = self
        self.txtFieldSubject.delegate = self
        viewModel.delegate = self
        viewModel.getContacts(site: .secondMovement, completion: { json in})
        viewModel.getContacts(site: .ethos, completion: { json in})
        self.addTapGestureToDissmissKeyBoard()
        self.lblDescription.setAttributedTitleWithProperties(title: "Get in touch with us by filling out the form below. We’re also available from Monday to Saturday, between 10:30 am to 6:30 pm, IST. You can write to us or call us on the below contact details provided. We will be happy to hear from you.", font: EthosFont.Brother1816Regular(size: 12), alignment: .center, lineHeightMultiple: 1.32, kern: 0.5)
        self.lblTitle1.setAttributedTitleWithProperties(title: "CONTACT ETHOS WATCH BOUTIQUE", font: EthosFont.Brother1816Medium(size: 12), kern: 1)
        self.lblTitle2.setAttributedTitleWithProperties(title: "CONTACT PRE-OWNED", font: EthosFont.Brother1816Medium(size: 12), kern: 1)
        
        self.btnMessage.setAttributedTitleWithProperties(title: "SEND A MESSAGE", font: EthosFont.Brother1816Regular(size: 12),foregroundColor: .white, backgroundColor: .clear, lineHeightMultiple: 1.5, kern: 1)
        
        self.txtFieldName.returnKeyType = .next
        self.txtFieldEmail.returnKeyType = .next
        self.txtFieldPhoneNumber.returnKeyType = .next
        self.txtFieldCity.returnKeyType = .next
        self.txtFieldMessage.returnKeyType = .send
        self.txtFieldSubject.returnKeyType = .next
       
        
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let nextButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(enableTextFieldCity))
        keyboardToolbar.setItems([flexibleSpace,nextButton], animated: true)
        txtFieldPhoneNumber.inputAccessoryView = keyboardToolbar
        
    }
    
    @objc func enableTextFieldCity() {
        self.txtFieldSubject.becomeFirstResponder()
    }
    
    func setTextFields() {
        self.txtFieldName.initWithUIParameters(placeHolderText: EthosConstants.YourFullName, placeholderColor: .black, underLineColor: EthosColor.seperatorColor, textInset: 0)
        self.txtFieldEmail.initWithUIParameters(placeHolderText: EthosConstants.YourEmailAddress, placeholderColor: .black, underLineColor: EthosColor.seperatorColor, textInset: 0)
        self.txtFieldPhoneNumber.initWithUIParameters(placeHolderText: EthosConstants.YourMobileNumber, placeholderColor: .black, underLineColor: EthosColor.seperatorColor, textInset: 0)
        self.txtFieldCity.initWithUIParameters(placeHolderText: EthosConstants.EnterYourCity, placeholderColor: .black, underLineColor: EthosColor.seperatorColor, textInset: 0)
        self.txtFieldSubject.initWithUIParameters(placeHolderText: EthosConstants.EnterSubject, placeholderColor: .black, underLineColor: EthosColor.seperatorColor, textInset: 0)
        self.txtFieldMessage.initWithUIParameters(placeHolderText: EthosConstants.WriteYourMessage, placeholderColor: .black, underLineColor: EthosColor.seperatorColor, textInset: 0)
        autoFillFields()
    }
    
    func autoFillFields() {
        txtFieldName.text = ((Userpreference.firstName ?? "") + " " + (Userpreference.lastName ?? "")).trimmingCharacters(in: .whitespacesAndNewlines)
        txtFieldEmail.text = Userpreference.email
        txtFieldPhoneNumber.text = Userpreference.phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines)
        txtFieldCity.text = Userpreference.location?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func validateFields() -> Bool {
        
        var valid = true
        
        if txtFieldName.validateAgainstName() == false {
             valid = false
        }
        
        if txtFieldEmail.validateAgainstEmail() == false {
             valid = false
        }
        
        if txtFieldPhoneNumber.validateAgainstPhoneNumber() == false {
             valid = false
        }
        
        if txtFieldSubject.validateAgainstSubject() == false {
             valid = false
        }
        
        if txtFieldCity.validateAgainstCity() == false {
             valid = false
        }
        
        if (txtFieldMessage.text?.isBlank ?? true) {
            viewMessage.showBottomError(str: EthosConstants.PleaseWriteMessage)
            valid = false
        } else if txtFieldMessage.text?.count ?? 0 < 5 {
            viewMessage.showBottomError(str: EthosConstants.PleaseEnterAtLeast5Characters)
            valid = false
        } else {
            viewMessage.removeBottomError()
        }
        
        return valid
    }
    
    @IBAction func btnSendMessage(_ sender: UIButton) {
        self.view.endEditing(true)
        if validateFields() {
            if let name = self.txtFieldName.text,
               let email = self.txtFieldEmail.text,
               let phone = self.txtFieldPhoneNumber.text,
               let city = self.txtFieldCity.text,
               let message = self.txtFieldMessage.text,
               let subject = self.txtFieldSubject.text {
                let params = [
                    EthosConstants.name : name,
                    EthosConstants.message : message,
                    EthosConstants.location : city,
                    EthosConstants.phone : phone,
                    EthosConstants.email : email,
                    EthosConstants.city : city,
                    EthosConstants.subject : subject
                ]
                self.viewModel.callApiForContactUs(params: params)
            }
        }
    }
    
    @IBAction func btnBackDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func resetFields() {
        self.txtFieldName.text = ""
        self.txtFieldEmail.text = ""
        self.txtFieldCity.text = ""
        self.txtFieldPhoneNumber.text = ""
        self.txtFieldSubject.text = ""
        self.txtFieldMessage.text = ""
        autoFillFields()
    }
    
    @IBAction func btnNumberDidTapped(_ sender : UIButton) {
        let phoneNumber = sender.titleLabel?.text?.replacingOccurrences(of: " " , with:  "") ?? ""
        if let numberUrl = URL(string: "tel://\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(numberUrl) {
                UIApplication.shared.open(numberUrl)
            }
        }
    }
    
    @IBAction func btnEmailDidTapped(_ sender : UIButton) {
        let phoneNumber = sender.titleLabel?.text?.replacingOccurrences(of: " " , with:  "") ?? ""
        if let numberUrl = URL(string: "mailto:\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(numberUrl) {
                UIApplication.shared.open(numberUrl)
            }
        }
    }
    
    @IBAction func btnWatsappNumberDidTapped(_ sender : UIButton) {
        let phoneNumber = sender.titleLabel?.text?.replacingOccurrences(of: " " , with:  "") ?? ""
        let urlWhats = "whatsapp://send?phone=\(phoneNumber)&abid=12354&text=Hello"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            if let watsappURL = URL(string: urlString), UIApplication.shared.canOpenURL(watsappURL) {
                    UIApplication.shared.open(watsappURL)
            } else if let watsappURL =  URL(string: "https://itunes.apple.com/app/id310633997"), UIApplication.shared.canOpenURL(watsappURL) {
                UIApplication.shared.open(watsappURL)
            }
        }
    }
}

extension ContactUsViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case txtFieldName : txtFieldEmail.becomeFirstResponder()
        case txtFieldEmail : txtFieldPhoneNumber.becomeFirstResponder()
        case txtFieldPhoneNumber : txtFieldSubject.becomeFirstResponder()
        case txtFieldSubject : txtFieldCity.becomeFirstResponder()
        case txtFieldCity : txtFieldMessage.becomeFirstResponder()
        case txtFieldMessage : self.btnSendMessage(self.btnMessage)
        default:
            break
        }
        return true
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var maxLength = 30
        
        if textField == txtFieldName {
            maxLength = 30
        }
        
        if textField == txtFieldPhoneNumber {
            maxLength = 10
        }
        
        if textField == txtFieldCity {
            maxLength = 30
        }
        
        if textField == txtFieldEmail {
            maxLength = 50
        }
        
        if textField == txtFieldSubject {
            maxLength = 30
        }
        
        if textField == txtFieldMessage {
            maxLength = 30
        }
    
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxLength
    }
}

extension ContactUsViewController : ContactUsViewModelDelegate {
    func didGetContacts(json: [String : Any], site : Site) {
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
                                self.lwh1.setTitle(newValue, for: .normal)
                            }
                            
                        case "Luxery Watch HelpLIne 2" :
                            if site == .ethos {
                                self.lwh2.setTitle(newValue, for: .normal)
                            }
                            
                        case "Online Orders Helpline 1" :
                            if site == .ethos {
                                self.ooh1.setTitle(newValue, for: .normal)
                            }
                            
                        case "Online Orders Helpline 2" :
                            if site == .ethos {
                                self.ooh2.setTitle(newValue, for: .normal)
                            }
                            
                        case "Email Us" :
                            if site == .ethos {
                                self.email.setTitle(newValue, for: .normal)
                            }
                            
                        case "Customer Care Number" :
                            if site == .ethos {
                                self.ccn1.setTitle(newValue, for: .normal)
                            } else {
                                self.smGQ.setTitle(newValue, for: .normal)
                            }
                            
                        case "Customer Care number" :
                            if site == .ethos {
                                self.ccn1.setTitle(newValue, for: .normal)
                            } else {
                                self.smGQ.setTitle(newValue, for: .normal)
                            }
                            
                        case "To Buy A Watch" :
                            if site == .secondMovement {
                                self.smBuyWatch.setTitle(newValue, for: .normal)
                            }
                            
                        case "To Sell A Watch" :
                            if site == .secondMovement {
                                self.smSellWatch.setTitle(newValue, for: .normal)
                            }
                            
                        case "General Queries" :
                            if site == .secondMovement {
                                self.smGQ.setTitle(newValue, for: .normal)
                            }
                            
                            
                        case "Whats App 1" :
                            if site == .secondMovement {
                                self.smWA.setTitle(newValue, for: .normal)
                            }
                            
                        case "Service center address" :
                            
                            if site == .ethos {
                             
                            }
                            
                        case "Whats App" :
                            if site == .ethos {
                               
                            }
                        default : break
                            
                        }
                    }
                }
            }
        }
    }
    
    func requestSuccess(message: String) {
        DispatchQueue.main.async {
            self.resetFields()
            self.showAlertWithSingleTitle(title: EthosConstants.requestSuccess, message: "" )
        }
        
    }
    
    func requestFailure(error: String) {
        DispatchQueue.main.async {
            self.showAlertWithSingleTitle(title: EthosConstants.requestFailed, message: "" )
        }}
    
    func startIndicator() {
        DispatchQueue.main.async {
            self.btnMessage.backgroundColor = .gray
            self.btnMessage.isEnabled = false
            self.indicator.startAnimating()
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.btnMessage.backgroundColor = .black
            self.btnMessage.isEnabled = true
            self.indicator.stopAnimating()
        }
    }
}
