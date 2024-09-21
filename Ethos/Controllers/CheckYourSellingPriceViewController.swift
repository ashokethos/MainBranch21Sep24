//
//  CheckYourSellingPriceViewController.swift
//  Ethos
//
//  Created by mac on 19/09/23.
//

import UIKit
import Mixpanel

class CheckYourSellingPriceViewController: UIViewController {
    @IBOutlet weak var tf1: EthosTextField!
    @IBOutlet weak var tf2: EthosTextField!
    @IBOutlet weak var tf3: EthosTextField!
    @IBOutlet weak var tf4: EthosTextField!
    
    @IBOutlet weak var lblCheckMarkText: UILabel!
    @IBOutlet weak var constraintBottom: NSLayoutConstraint!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnCheckmark: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var lblSku: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var cancelTopBtn: UIButton!
    
    var product : Product?
    var isShowingKeyBoard : Bool = false
    var isForPreOwned : Bool = false
    let viewModel = CheckOurSellingPriceViewModel()
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.setKeyBoard()
        
        viewModel.delegate = self
        self.viewMain.layer.masksToBounds = true
        self.viewMain.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.viewMain.layer.cornerRadius = 25
        self.btnCheckmark.isSelected = true
        
        tf1.delegate = self
        tf2.delegate = self
        tf3.delegate = self
        tf4.delegate = self
        
        tf1.returnKeyType = .next
        tf2.returnKeyType = .next
        tf3.returnKeyType = .next
        tf4.returnKeyType = .send
        
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        if let product = self.product {
            var title = ""
            if product.name ?? "" != ""{
                title = (product.name ?? "").replacingOccurrences(of: "+", with: " ")
            }else{
                let productName = product.extensionAttributes?.ethProdCustomeData?.productName ?? ""
                
                let productBrand = product.extensionAttributes?.ethProdCustomeData?.brand ?? ""
                
                title = productBrand + " " + productName
                
                if title.last == " " {
                    title.removeLast()
                }
                
                title = title.replacingOccurrences(of: "+", with: " ")
            }
            
            self.lblProductName.text = title
            self.lblSku.text = (product.sku ?? "").replacingOccurrences(of: "+", with: " ")
            self.lblCheckMarkText.setAttributedTitleWithProperties(
                title: self.isForPreOwned ? EthosConstants.KeepMeUpdateMessageSecondMovement : EthosConstants.KeepMeUpdateMessageEthos,
                font: EthosFont.Brother1816Regular(size: 12)
            )
        }
        
        tf1.initWithUIParameters(placeHolderText: EthosConstants.FullName, underLineColor: EthosColor.seperatorColor, textInset: 0)
        tf2.initWithUIParameters(placeHolderText: EthosConstants.EmailAddress,  underLineColor: EthosColor.seperatorColor, textInset: 0)
        tf3.initWithUIParameters(placeHolderText: EthosConstants.PhoneNumber, underLineColor: EthosColor.seperatorColor, textInset: 0)
        tf4.initWithUIParameters(placeHolderText: EthosConstants.City, underLineColor: EthosColor.seperatorColor, textInset: 0)
        
        autoFillFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func autoFillFields() {
        tf1.text = ((Userpreference.firstName ?? "") + " " + (Userpreference.lastName ?? "")).trimmingCharacters(in: .whitespacesAndNewlines)
        tf2.text = Userpreference.email
        tf3.text = Userpreference.phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines)
        tf4.text = Userpreference.location?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func setKeyBoard() {
        self.addTapGestureToDissmissKeyBoard()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
        
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let nextButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(enableTF4))
        keyboardToolbar.setItems([flexibleSpace,nextButton], animated: false)
        tf3.inputAccessoryView = keyboardToolbar
    }
    
    @objc func enableTF4() {
        self.tf4.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow() {
        self.isShowingKeyBoard = true
        self.constraintBottom.constant = 200
    }
    
    @objc func keyboardWillHide() {
        self.isShowingKeyBoard = false
        self.constraintBottom.constant = 0
    }
    
    func validateFields() -> Bool {
        
        var valid = true
        
        if tf1.validateAgainstName() == false {
            valid = false
        }
        
        if tf2.validateAgainstEmail() == false {
            valid = false
        }
        
        if tf3.validateAgainstPhoneNumber() == false {
            valid = false
        }
        
        if tf4.validateAgainstCity() == false {
            valid = false
        }
        
        return valid
    }
    
    @IBAction func cancelTopBtnAction(_ sender: UIButton) {
        if self.isShowingKeyBoard == false {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func didTapBtnCheckMark(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    
    @IBAction func btnTraparenViewDidTapped(_ sender: UIButton) {
        if self.isShowingKeyBoard == false {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func btnSubmitDidTapped(_ sender: UIButton) {
        if validateFields() {
            guard let product = product else { return }
            let params : [String : String] = [
                EthosConstants.Name: self.tf1.text ?? "",
                EthosConstants.Email : self.tf2.text ?? "",
                EthosConstants.Phone: self.tf3.text ?? "",
                EthosConstants.city: self.tf4.text ?? "",
                EthosConstants.Sku : (product.sku ?? "").replacingOccurrences(of: "+", with: " ")
            ]
            btnSubmit.isEnabled = false
            viewModel.callApiForCheckOurSellingPrice(product: product, params: params, site: self.isForPreOwned ? .secondMovement : .ethos)
        }
    }
}

extension CheckYourSellingPriceViewController : CheckOurSellingPriceViewModelDelegate {
    func startIndicator() {
        DispatchQueue.main.async {
            self.btnSubmit.isEnabled = false
            self.btnSubmit.backgroundColor = .gray
            self.indicator.startAnimating()
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.btnSubmit.isEnabled = true
            self.btnSubmit.backgroundColor = .black
            self.indicator.stopAnimating()
        }
    }
    
    func requestSuccess(message: String) {
        DispatchQueue.main.async {
            if let alertController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: EthosAlertController.self)) as? EthosAlertController {
                alertController.setActions(title: EthosConstants.requestReceivedMessage, message: "", secondActionTitle: "Ok", secondAction:  {
                    self.btnSubmit.isEnabled = true
                    self.dismiss(animated: true)
                })
                self.present(alertController, animated: true)
            }
        }
    }
    
    func requestFailure(error: String) {
        self.showAlertWithSingleTitle(title:EthosConstants.requestFailed, message: "", actionTitle: "Ok")
    }
    
    
}


extension CheckYourSellingPriceViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tf1 : tf2.becomeFirstResponder()
        case tf2 : tf3.becomeFirstResponder()
        case tf3 : tf4.becomeFirstResponder()
        case tf4 : 
            self.view.endEditing(true)
            btnSubmitDidTapped(self.btnSubmit)
            
        default:
            break
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        var maxLength = 30
        
        if textField == tf1 {
            maxLength = 30
        }
        
        if textField == tf2 {
            maxLength = 50
        }
        
        
        if textField == tf3 {
            maxLength = 10
        }
        
        if textField == tf4 {
            maxLength = 30
        }
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxLength
    }
    
}
