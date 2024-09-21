//
//  RequestACallBackFormViewController.swift
//  Ethos
//
//  Created by mac on 06/09/23.
//

import UIKit
import Mixpanel

class RequestACallBackFormViewController: UIViewController {
    @IBOutlet weak var tf1: EthosTextField!
    @IBOutlet weak var tf2: EthosTextField!
    @IBOutlet weak var tf3: EthosTextField!
    @IBOutlet weak var tf4: EthosTextField!
    @IBOutlet weak var tf5: EthosTextField!
    @IBOutlet weak var tf6: EthosTextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var btnSubmit: UIButton!
    
    var isShowingKeyBoard : Bool = false
    var isforPreOwned : Bool = false
    let brandViewModel = GetBrandsViewModel()
    let requestACallBackViewModel = RequestACallBackViewModel()
    var screenLocation : String = ""
    var selectedTabIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setKeyBoard()
        brandViewModel.delegate = self
        brandViewModel.getRequestACallBackBrands(site: self.isforPreOwned ? .secondMovement : .ethos)
        requestACallBackViewModel.delegate = self
        self.viewMain.layer.masksToBounds = true
        self.viewMain.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.viewMain.layer.cornerRadius = 25
        tf1.delegate = self
        tf2.delegate = self
        tf3.delegate = self
        tf4.delegate = self
        
        tf1.returnKeyType = .next
        tf2.returnKeyType = .next
        tf3.returnKeyType = .next
        tf4.returnKeyType = .continue
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        let rv1 = UIImageView(image: UIImage(named: EthosConstants.downArrow))
        let rv2 = UIImageView(image: UIImage(named: EthosConstants.downArrow))
        tf1.initWithUIParameters(placeHolderText: "Name", underLineColor: EthosColor.seperatorColor, leftViewWidth: 0,  rightViewWidth: 0, textInset: 0)
        tf2.initWithUIParameters(placeHolderText: "Email",  underLineColor: EthosColor.seperatorColor, leftViewWidth: 0, rightViewWidth: 0, textInset: 0)
        tf3.initWithUIParameters(placeHolderText: EthosConstants.PhoneNumber, underLineColor: EthosColor.seperatorColor, leftViewWidth: 0, rightViewWidth: 0, textInset: 0)
        tf4.initWithUIParameters(placeHolderText: "Your Location",  underLineColor: EthosColor.seperatorColor,  leftViewWidth: 0, rightViewWidth: 0, textInset: 0)
        tf5.initWithUIParameters(placeHolderText: "Please select your brand",  rightView: rv1,  underLineColor: EthosColor.seperatorColor,  leftViewWidth: 0, rightViewWidth: 10, textInset: 0)
        tf6.initWithUIParameters(placeHolderText: "Please select your concern", rightView: rv2,  underLineColor: EthosColor.seperatorColor, leftViewWidth: 0, rightViewWidth: 10, textInset: 0)
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
    }
    
    @objc func keyboardWillHide() {
        self.isShowingKeyBoard = false
    }
    
    var ArrListOfConcerns = ["My watch is not working" , "Strap/Breaclet requirement" , "Watch repair", "Watch service" , "Maintenance check"]
    
    var selectedBrand : FormBrand? {
        didSet {
            self.tf5.text = selectedBrand?.label ?? ""
        }
    }
    
    var selectedConcern : String? {
        didSet {
            self.tf6.text = selectedConcern
        }
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
        
        if tf4.validateAgainstLocation() == false {
            valid = false
        }
        
        if tf5.text?.isBlank ?? true || self.selectedBrand?.label == "" || self.selectedBrand?.label == nil {
            tf5.showError(str: "Please select brand")
            valid = false
        } else {
            tf5.removeError()
        }
        
        if tf6.text?.isBlank ?? true || self.selectedConcern == "" || self.selectedConcern == nil {
            tf6.showError(str: "Please select concern")
            valid = false
        } else {
            tf6.removeError()
        }
        
        return valid
    }
    
    
    @IBAction func btnSelectConcernDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: EthosBottomSheetTableViewController.self)) as? EthosBottomSheetTableViewController {
            vc.delegate = self
            vc.data = self.ArrListOfConcerns
            vc.selectedItem = self.selectedConcern ?? vc.data.first
            vc.key = .forSelectConcern
            vc.superController = self
            vc.selectedTabIndex = self.selectedTabIndex
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
        }
    }
    
    
    @IBAction func btnSelectBrandDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: EthosBottomSheetTableViewController.self)) as? EthosBottomSheetTableViewController {
            vc.key = .forSelectBrand
            vc.superController = self
            vc.data = self.brandViewModel.formBrands.map({ element in
                element.label ?? ""
            })
            vc.selectedItem = self.selectedBrand?.label ?? vc.data.first
            vc.selectedTabIndex = self.selectedTabIndex
            vc.delegate = self
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
        }
    }
    
    
    @IBAction func btnTraparenViewDidTapped(_ sender: UIButton) {
        if self.isShowingKeyBoard == false {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func btnSubmitDidTapped(_ sender: UIButton) {
        if validateFields() {
            let params : [String : String] = [
                EthosConstants.name: self.tf1.text ?? "",
                EthosConstants.email: self.tf2.text ?? "",
                EthosConstants.telephone: self.tf3.text ?? "",
                EthosConstants.phone: self.tf3.text ?? "",
                EthosConstants.location: self.tf4.text ?? "",
                EthosConstants.city: self.tf4.text ?? "",
                EthosConstants.brand: self.tf5.text ?? "",
                EthosConstants.comment: self.tf6.text ?? "",
                EthosConstants.message: self.tf6.text ?? "",
            ]
            
            Mixpanel.mainInstance().trackWithLogs(event: "Repair Call Back Requested", properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.ScreenLocation : self.screenLocation,
                
                EthosConstants.Name : self.tf1.text ?? "",
                EthosConstants.EmailAddress : self.tf2.text ?? "",
                
                EthosConstants.PhoneNumber : self.tf3.text ?? "",
                EthosConstants.CustomerLocation : self.tf4.text ?? "",
                EthosConstants.BrandSelected : self.tf5.text ?? "",
                EthosConstants.Concerns : self.tf6.text ?? ""
                
            ])
            
            requestACallBackViewModel.callApiForRequestCallBack(params: params, site: .secondMovement)
        }
    }
}

extension RequestACallBackFormViewController : GetBrandsViewModelDelegate {
    func didGetFormBrands(brands: [FormBrand]) {
        
    }
    
    func didGetBrands(brands: [BrandModel]) {
        
    }
    
    func didGetBrandsForSellOrTrade(brands: [BrandForSellOrTrade]) {
        
    }
    
    func errorInGettingBrands() {
        
    }
    
    func startIndicator() {
        DispatchQueue.main.async {
            self.btnSubmit.backgroundColor = .gray
            self.btnSubmit.isEnabled = false
            self.indicator.startAnimating()
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.btnSubmit.backgroundColor = .black
            self.btnSubmit.isEnabled = true
            self.indicator.stopAnimating()
        }
    }
}

extension RequestACallBackFormViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tf1 : tf2.becomeFirstResponder()
        case tf2 : tf3.becomeFirstResponder()
        case tf3 : tf4.becomeFirstResponder()
        case tf4 : self.view.endEditing(true)
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

extension RequestACallBackFormViewController : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        if let key = info?[EthosKeys.key] as? EthosKeys,
           key == .reloadCollectionView,
           let value = info?[EthosKeys.value] as? String,
           let bottomSheetKey : BottomSheetKey = info?[EthosKeys.type] as? BottomSheetKey {
            switch bottomSheetKey {
            case .forSelectBrand:
                self.selectedBrand = brandViewModel.formBrands.first(where: { brand in
                    brand.label == value
                })
            case .forSelectConcern:
                self.selectedConcern = value
            case .forSortBy:
                break
            case .forPhoneNumber:
                break
            }
        }
    }
}

extension RequestACallBackFormViewController : RequestACallBackViewModelDelegate {
    func requestSuccess() {
        DispatchQueue.main.async {
            if let alertController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: EthosAlertController.self)) as? EthosAlertController {
                alertController.setActions(title: EthosConstants.requestSuccess, message: "", secondActionTitle: "Ok", secondAction:  {
                    self.dismiss(animated: true)
                })
                self.present(alertController, animated: true)
            }
        }
    }
    
    func requestFailure() {
        self.showAlertWithSingleTitle(title: EthosConstants.requestFailed, message: "", actionTitle: "Ok")
    }
    
    
}

