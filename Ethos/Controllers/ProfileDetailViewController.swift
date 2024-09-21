//
//  ProfileDetailViewController.swift
//  Ethos
//
//  Created by mac on 02/08/23.
//

import UIKit
import PhotosUI
import libPhoneNumber
import Mixpanel

class ProfileDetailViewController: UIViewController {
    
    @IBOutlet weak var btnUploadImage: UIButton!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var textFieldName: EthosTextField!
    @IBOutlet weak var textFieldMobileNumber: EthosTextField!
    @IBOutlet weak var textFieldEmail: EthosTextField!
    @IBOutlet weak var textFieldDOB: EthosTextField!
    @IBOutlet weak var textFieldOccupation: EthosTextField!
    @IBOutlet weak var textFieldLocation: EthosTextField!
    @IBOutlet weak var textFieldWatchBrand: EthosTextField!
    @IBOutlet weak var textFieldChangePassword: EthosTextField!
    @IBOutlet weak var btnGenderMale: UIButton!
    @IBOutlet weak var btnGenderFemale: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var downArrow: UIImageView!
    @IBOutlet weak var btnWatchBrand: UIButton!
    @IBOutlet weak var viewMobileNumber: UIView!
    @IBOutlet weak var viewWatchBrand: UIView!
    @IBOutlet weak var viewChangePassword: UIView!
    @IBOutlet weak var collectionViewBrands: UICollectionView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var btnCountryCode: UIButton!
    
    var ArrFavouriteWatchBrand = [BrandModel]()
    let viewModel = GetBrandsViewModel()
    var customerModel = GetCustomerViewModel()
    var datePicker = UIDatePicker()
    var delegate : SuperViewDelegate?
    
    var phoneNumberlimit : Int = 10
    
    var country : Country = Country(name: "India", dialCode: "+91", code: "IN") {
        didSet {
            DispatchQueue.main.async {
                self.btnCountryCode.setTitle(self.country.dialCode, for: .normal)
                let util = NBPhoneNumberUtil(metadataHelper: NBMetadataHelper())
                let exampleNumber = try?  util?.getExampleNumber(self.country.code)
                self.phoneNumberlimit = exampleNumber?.nationalNumber.stringValue.count ?? 10
                self.textFieldMobileNumber.text = ""
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        self.textFieldEmail.isEnabled = false
        self.textFieldMobileNumber.isEnabled = false
        self.btnCountryCode.isEnabled = false
        
        if let date = Calendar.current.date(byAdding: .year, value: -15, to: Date()) {
            datePicker.maximumDate = date
        }
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        self.textFieldDOB.inputView = datePicker
        self.textFieldDOB.delegate = self
        self.textFieldName.delegate = self
        self.textFieldOccupation.delegate = self
        self.textFieldEmail.delegate = self
        self.textFieldMobileNumber.delegate = self
        self.textFieldLocation.delegate = self
        
        viewModel.getBrands(site: .ethos, isAscending: true, includeRolex: false)
        viewModel.delegate = self
        customerModel.delegate = self
        self.collectionViewBrands.registerCell(className: DeletableTextCollectionViewCell.self)
        self.customerModel.getCustomerDetails()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
      
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        setTextFields()
        if let customer = customerModel.customer {
            self.setUI(customer: customer)
        }
    }
    
    func setUI(customer : Customer) {
        for attribute in customer.customAttributes ?? [] {
            if attribute.attributeCode == "mobile" {
                self.textFieldMobileNumber.text = attribute.value
            }
        }
        
        self.textFieldName.text = (customer.firstname ?? "") + " " + (customer.lastname ?? "")
        self.textFieldEmail.text = customer.email ?? ""
        
        self.textFieldLocation.text = customer.extraAttributes?.location ?? ""
        self.textFieldOccupation.text = customer.extraAttributes?.occupation ?? ""
        
        self.textFieldDOB.text = customer.dateOfBirth ?? ""
        
        if let gender = customer.gender {
            if gender == "male" {
                self.btnGenderMale.isSelected = true
                self.btnGenderFemale.isSelected = false
            } else {
                self.btnGenderFemale.isSelected = true
                self.btnGenderMale.isSelected = false
            }
        }
        
        self.ArrFavouriteWatchBrand = customer.extraAttributes?.favouriteBrand ?? []
        
        if let image = customer.extraAttributes?.profileImage {
            UIImage.loadFromURL(url: image) { image in
                self.imageProfile.image = image
            }
        }
        
        self.reloadUI()
        
    }
    
    func setup() {
        self.addTapGestureToDissmissKeyBoard()
        self.setBorders()
    }
    
    func setBorders() {
        self.imageProfile.setBorder(borderWidth: 0.1, borderColor: EthosColor.seperatorColor, radius: 50)
    }
    
    func setTextFields() {
        self.textFieldName.initWithUIParameters(placeHolderText: EthosConstants.YourName, underLineColor: EthosColor.seperatorColor, textInset: 0)
        self.textFieldMobileNumber.initWithUIParameters(placeHolderText: EthosConstants.MobileNumber, textInset: 0)
        self.textFieldEmail.initWithUIParameters(placeHolderText: EthosConstants.Email, underLineColor: EthosColor.seperatorColor, textInset: 0)
        self.textFieldDOB.initWithUIParameters(placeHolderText: EthosConstants.DateOfBirth, underLineColor: EthosColor.seperatorColor, textInset: 0)
        self.textFieldOccupation.initWithUIParameters(placeHolderText: EthosConstants.Occupation, underLineColor: EthosColor.seperatorColor, textInset: 0)
        self.textFieldLocation.initWithUIParameters(placeHolderText: EthosConstants.Location, underLineColor: EthosColor.seperatorColor, textInset: 0)
        self.textFieldWatchBrand.initWithUIParameters(placeHolderText: EthosConstants.FavouriteWatchBrand, underLineColor: EthosColor.seperatorColor, textInset: 0)
        self.textFieldChangePassword.initWithUIParameters(placeHolderText: EthosConstants.ChangePassword, underLineColor: EthosColor.seperatorColor, textInset: 0)
    }
    
    @IBAction func btnSaveBtnDidTapped(_ sender: UIButton) {
        if validateFields() {
            let email = self.textFieldEmail.text ?? ""
            let phone = self.textFieldMobileNumber.text ?? ""
            let dob = self.textFieldDOB.text ?? ""
            let location = textFieldLocation.text ?? ""
            let name = self.textFieldName.text ?? ""
            let occupation = self.textFieldOccupation.text ?? ""
            
            if let id  = customerModel.customer?.id {
                var params: [String : Any] = ["id" : id]
                var customAttributtes = [[String : Any]]()
                var extraAttributes = [String : Any]()
                var favouriteBrands = [[String : Any]]()
                
                
                params["email"] = email
                params["name"] = name
                params ["dob"] = dob
                customAttributtes.append(["attribute_code" :  "mobile" , EthosConstants.value : phone])
                
                
                
                if self.btnGenderMale.isSelected {
                    params["gender"] = "1"
                }
                
                if self.btnGenderFemale.isSelected {
                    params["gender"] = "2"
                }
                
                
                extraAttributes["location"] = location
                extraAttributes["occupation"] = occupation
                
                for brand in ArrFavouriteWatchBrand {
                    if let id = brand.id,
                       let name = brand.name {
                        favouriteBrands.append(["id" : id, EthosConstants.brand : name])
                    }
                }
                
                extraAttributes["favorite_brand"] =  favouriteBrands
                params["extra_attributes"] = extraAttributes
                params["custom_attributes"] = customAttributtes
                self.customerModel.updateProfile(params: params)
            }
        }
    }
    
    @IBAction func btnCountryCodeDidTapped(_ sender: UIButton) {
        if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosTableViewController.self)) as? EthosTableViewController {
            vc.key = .country
            vc.delegate = self
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func btnUploadImageDidTapped(_ sender: UIButton) {
        if Userpreference.token != nil {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true)
        }
    }
    
    @IBAction func collectionViewDidTapped(_ sender: UITapGestureRecognizer) {
        self.btnFavouriteBrandDidTapped(self.btnWatchBrand)
    }
    
    @IBAction func selectGenderButton(_ sender: UIButton) {
        sender.isSelected = true
        if sender == btnGenderMale {
            btnGenderFemale.isSelected = false
        } else {
            btnGenderMale.isSelected = false
        }
    }
    
    @IBAction func btnBackDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnUpdateDidTapped(_ sender: UIButton) {
        if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: PasswordChangeAlertController.self)) as? PasswordChangeAlertController {
            vc.delegate = self
            self.present(vc, animated: true)
        }
    }
    
    func reloadUI() {
        self.collectionViewBrands.isHidden =  self.ArrFavouriteWatchBrand.isEmpty
        self.btnWatchBrand.isHidden = !self.ArrFavouriteWatchBrand.isEmpty
        self.textFieldWatchBrand.isHidden = !self.ArrFavouriteWatchBrand.isEmpty
        self.downArrow.isHidden = !self.ArrFavouriteWatchBrand.isEmpty
        
        
        if self.textFieldEmail.text?.isEmpty == true {
            self.textFieldEmail.isEnabled = true
        } else {
            self.textFieldEmail.isEnabled = false
        }
        
        if self .textFieldMobileNumber.text?.isEmpty == true {
            self.textFieldMobileNumber.isEnabled = true
            self.btnCountryCode.isEnabled = true
        } else {
            self.textFieldMobileNumber.isEnabled = false
            self.btnCountryCode.isEnabled = false
        }
        
        self.collectionViewBrands.reloadData()
    }
    
    @IBAction func btnFavouriteBrandDidTapped(_ sender: UIButton) {
        
        if self.viewModel.brands.count > 0 {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: EthosBottomSheetTableViewController.self)) as? EthosBottomSheetTableViewController {
                vc.forMultipleSelection = true
                vc.delegate = self
                vc.superController = self
                vc.selectedItems = self.ArrFavouriteWatchBrand.map({ item in
                    item.name ?? ""
                })
                vc.data = viewModel.brands.map({ brand in
                    brand.name ?? ""
                })
                self.present(vc, animated: true)
            }
        }
    }
    
    
    func validateFields() -> Bool {
        
        var valid = true
        
        if self.textFieldName.validateAgainstFullName() == false {
            valid = false
        }
        
        if self.textFieldDOB.text?.isBlank ?? true {
            self.textFieldDOB.showError(str: "Please enter date of birth")
            valid = false
        } else {
            self.textFieldDOB.removeError()
        }
        
        if self.textFieldOccupation.text?.isBlank ?? true {
            self.textFieldOccupation.showError(str: "Please enter occupation")
            valid = false
        } else if self.textFieldOccupation.text?.containsOneSpecialCharacterForNCS == true {
            self.textFieldOccupation.showError(str: "Special characters not allowed")
            valid = false
        } else {
            self.textFieldOccupation.removeError()
        }
        
        if self.textFieldLocation.validateAgainstCity() == false {
            valid = false
        }
        
        if !btnGenderMale.isSelected && !btnGenderFemale.isSelected {
            btnGenderMale.shake()
            btnGenderFemale.shake()
            valid = false
        }
        
        return valid
    }
}

extension ProfileDetailViewController : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        if let key = info?[EthosKeys.key] as? EthosKeys,  key == .reloadCollectionView, let values = info?[EthosKeys.value] as? [String] {
            self.ArrFavouriteWatchBrand.removeAll()
            for value in values {
                for brand in viewModel.brands {
                    if brand.name == value {
                        self.ArrFavouriteWatchBrand.append(brand)
                    }
                }
            }
            reloadUI()
        }
        
        if let key = info?[EthosKeys.key] as? EthosKeys,  key == .delete, let index = info?[EthosKeys.currentIndex] as? Int {
            if index < self.ArrFavouriteWatchBrand.count {
                ArrFavouriteWatchBrand.remove(at: index)
                reloadUI()
            }
        }
        
        
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.route {
            if let vc = UIStoryboard(name: StoryBoard.login.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: ForgotPasswordViewController.self)) as? ForgotPasswordViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.updateView {
            if let country : Country = info?[EthosKeys.value] as? Country {
                self.country = country
            }
        }
    }
}

extension ProfileDetailViewController : GetCustomerViewModelDelegate {

    func userDeleteSuccess() {
        
    }
    
    func userDeleteFailed(error: String) {
        
    }
    
    func didGetCustomerPoints(points: Int) {
        
    }
    
    func didGetCustomerData(data: Customer) {
        DispatchQueue.main.async {
            if let customer = self.customerModel.customer {
                self.setUI(customer: customer)
            }
        }
    }
    
    func unAuthorizedToken(message: String) {
        
    }
    
    func startProfileIndicator() {
        DispatchQueue.main.async {
            self.showActivityIndicator()
//            self.indicator.startAnimating()
        }
    }
    
    func stopProfileIndicator() {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
//            self.indicator.stopAnimating()
        }
    }
    
    func updateProfileSuccess(message: String) {
        DispatchQueue.main.async {
            self.customerModel.getCustomerDetails()
            if let alertController = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosAlertController.self)) as? EthosAlertController {
                alertController.setActions(title: message, message: "", secondActionTitle: "Done")
                self.present(alertController, animated: true)
            }
        }
    }
    
    func updateProfileFailed(message: String) {
        DispatchQueue.main.async {
            self.customerModel.getCustomerDetails()
        }
    }
}

extension ProfileDetailViewController : GetBrandsViewModelDelegate {
    
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
            self.indicator.startAnimating()
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
        }
    }
    
    
}

extension ProfileDetailViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ArrFavouriteWatchBrand.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: DeletableTextCollectionViewCell.self), for: indexPath) as? DeletableTextCollectionViewCell {
            cell.index = indexPath.item
            cell.btnDelete.tag = indexPath.item
            cell.lblTitle.text = ArrFavouriteWatchBrand[indexPath.item].name
            cell.delegate = self
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        btnFavouriteBrandDidTapped(self.btnWatchBrand)
    }
}

extension ProfileDetailViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var maxLength = 30
        
        if textField == textFieldName {
            maxLength = 30
        }
        
        if textField == textFieldMobileNumber {
            maxLength = self.phoneNumberlimit
        }
        
        if textField == textFieldOccupation {
            maxLength = 30
        }
        
        if textField == textFieldEmail {
            maxLength = 50
        }
        
        if textField == textFieldDOB {
            maxLength = 30
        }
        
        if textField == textFieldLocation {
            maxLength = 30
        }
        
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxLength
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.textFieldDOB {
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"
            dateformatter.timeZone = .current
            textFieldDOB.text = dateformatter.string(from: datePicker.date)
        }
    }
}



extension ProfileDetailViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                
                let imgData = NSData(data: image.jpegData(compressionQuality: 1) ?? Data())
                let imageSize: Int = imgData.count
                let imageSizeinKB = imageSize/1024
                guard imageSizeinKB < 2042 else {
                    self.showAlertWithSingleTitle(title: "Too big Image", message: "", actionTitle: "OK")
                    return
                }
                self.customerModel.updateProfileImage(images: [image]) { image in
                    DispatchQueue.main.async {
                        self.imageProfile.image = image
                    }
                }
            }
        }
    }
}
