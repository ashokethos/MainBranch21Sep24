//
//  ScheduleAPickupViewController.swift
//  Ethos
//
//  Created by mac on 22/02/24.
//

import UIKit
import Mixpanel

class ScheduleAPickupViewController: UIViewController {
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
    
    var selectedTabIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setKeyBoard()
        brandViewModel.delegate = self
        brandViewModel.getSchedulePickupBrands(site: self.isforPreOwned ? .secondMovement : .ethos)
        requestACallBackViewModel.delegate = self
        self.viewMain.layer.masksToBounds = true
        self.viewMain.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.viewMain.layer.cornerRadius = 25
        
        tf1.delegate = self
        tf2.delegate = self
        tf3.delegate = self
        tf4.delegate = self
        tf5.delegate = self
        tf6.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
      
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        setTextFields()
    }
    
    func setTextFields() {
        let rv1 = UIImageView(image: UIImage(named: EthosConstants.downArrow))
        
        tf1.initWithUIParameters(placeHolderText: "Full Name", underLineColor: EthosColor.seperatorColor, leftViewWidth: 0, rightViewWidth: 0, textInset: 0)
        tf2.initWithUIParameters(placeHolderText: "Email", underLineColor: EthosColor.seperatorColor,  leftViewWidth: 0, rightViewWidth: 0, textInset: 0)
        tf3.initWithUIParameters(placeHolderText: EthosConstants.PhoneNumber, underLineColor: EthosColor.seperatorColor,  leftViewWidth: 0, rightViewWidth: 0, textInset: 0)
        tf4.initWithUIParameters(placeHolderText: "Pin Code", underLineColor: EthosColor.seperatorColor,  leftViewWidth: 0, rightViewWidth: 0, textInset: 0)
        tf5.initWithUIParameters(placeHolderText: "Pickup City", underLineColor: EthosColor.seperatorColor,  leftViewWidth: 0, rightViewWidth: 0, textInset: 0)
        tf6.initWithUIParameters(placeHolderText: "Please select your brand",  rightView: rv1, underLineColor: EthosColor.seperatorColor, leftViewWidth: 0, rightViewWidth: 10, textInset: 0)
        autoFillFields()
        
        tf1.returnKeyType = .next
        tf2.returnKeyType = .next
        tf3.returnKeyType = .next
        tf4.returnKeyType = .next
        tf4.returnKeyType = .continue
        
        
    }
    
    func autoFillFields() {
        tf1.text = ((Userpreference.firstName ?? "") + " " + (Userpreference.lastName ?? "")).trimmingCharacters(in: .whitespacesAndNewlines)
        tf2.text = Userpreference.email
        tf3.text = Userpreference.phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines)
        tf5.text = Userpreference.location?.trimmingCharacters(in: .whitespacesAndNewlines)
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
        keyboardToolbar.setItems([flexibleSpace,nextButton], animated: true)
        tf3.inputAccessoryView = keyboardToolbar
        
        
        let keyboardToolbar1 = UIToolbar()
        keyboardToolbar1.sizeToFit()
        let flexibleSpace1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let nextButton1 = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(enableTF5))
        keyboardToolbar1.setItems([flexibleSpace1,nextButton1], animated: true)
        tf4.inputAccessoryView = keyboardToolbar1
    }
    
    @objc func enableTF4() {
        self.tf4.becomeFirstResponder()
    }
    
    @objc func enableTF5() {
        self.tf5.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true)
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
            self.tf6.text = selectedBrand?.label ?? ""
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
        
        if tf4.text?.isBlank ?? true {
            tf4.showError(str: "Please enter pin code")
            valid = false
        } else if tf4.text?.count != 6 {
            tf4.showError(str: "Please enter valid pin code")
            valid = false
        } else {
            tf4.removeError()
        }
        
        if tf5.validateAgainstCity() == false {
            valid = false
        }
        
        if tf6.text?.isBlank ?? true || self.selectedBrand?.label == "" || self.selectedBrand == nil {
            valid = false
            tf6.showError(str: "Please select brand")
        } else {
            tf6.removeError()
        }
        
        return valid
    }
    
    @IBAction func btnSelectBrandDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: EthosBottomSheetTableViewController.self)) as? EthosBottomSheetTableViewController {
            vc.key = .forSelectBrand
            vc.data = self.brandViewModel.formBrands.map({ element in
                element.label ?? ""
            })
            vc.selectedTabIndex = self.selectedTabIndex
            vc.selectedItem = self.selectedBrand?.label ?? vc.data.first
            vc.delegate = self
            vc.superController = self
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
                EthosConstants.pincode: self.tf4.text ?? "",
                EthosConstants.city: self.tf5.text ?? "",
                EthosConstants.brand: self.tf6.text ?? "",
            ]
            
            requestACallBackViewModel.callApiForSchedulePickup(params: params, site: .secondMovement)
        }
    }
}

extension ScheduleAPickupViewController : GetBrandsViewModelDelegate {
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

extension ScheduleAPickupViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tf1 : tf2.becomeFirstResponder()
        case tf2 : tf3.becomeFirstResponder()
        case tf3 : tf4.becomeFirstResponder()
        case tf4 : tf5.becomeFirstResponder()
        case tf5 : self.view.endEditing(true)
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
            maxLength = 6
        }
        
        if textField == tf5 {
            maxLength = 50
        }
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxLength
    }
}

extension ScheduleAPickupViewController : SuperViewDelegate {
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
                break
            case .forSortBy:
                break
            case .forPhoneNumber:
                break
            }
        }
    }
}

extension ScheduleAPickupViewController : RequestACallBackViewModelDelegate {
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
        self.showAlertWithSingleTitle(title: EthosConstants.requestFailed, message: "", actionTitle: "OK")
    }
    
    
}


