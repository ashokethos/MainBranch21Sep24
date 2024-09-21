//
//  GetAQuoteTradeTableViewCell.swift
//  Ethos
//
//  Created by mac on 21/08/23.
//

import UIKit

class GetAQuoteTradeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgBulletFirst: UIImageView!
    @IBOutlet weak var imgBulletSecond: UIImageView!
    @IBOutlet weak var lblSubHeadingFirst: UILabel!
    @IBOutlet weak var imgBulletThird: UIImageView!
    @IBOutlet weak var lblSubHeadingSecond: UILabel!
    @IBOutlet weak var lblSubHeadingThird: UILabel!
    @IBOutlet weak var lblCheckBox: UILabel!
    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var lblHeadingBrand: UILabel!
    @IBOutlet weak var txtFieldBrand: EthosTextField!
    @IBOutlet weak var viewBrand: UIView!
    @IBOutlet weak var superViewBrand: UIView!
    @IBOutlet weak var lblHeadingModel: UILabel!
    @IBOutlet weak var txtFieldModel: EthosTextField!
    @IBOutlet weak var viewModel: UIView!
    @IBOutlet weak var superViewModel: UIView!
    @IBOutlet weak var lblHeadingPhoto: UILabel!
    @IBOutlet weak var viewPhoto: UIView!
    @IBOutlet weak var superViewPhoto: UIView!
    @IBOutlet weak var lblHeadingName: UILabel!
    @IBOutlet weak var txtFieldName: EthosTextField!
    @IBOutlet weak var viewName: UIView!
    @IBOutlet weak var superViewName: UIView!
    @IBOutlet weak var lblHeadingEmail: UILabel!
    @IBOutlet weak var txtFieldEmail: EthosTextField!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var superViewEmail: UIView!
    @IBOutlet weak var lblHeadingPhone: UILabel!
    @IBOutlet weak var txtFieldPhone: EthosTextField!
    @IBOutlet weak var viewPhone: UIView!
    @IBOutlet weak var superViewPhone: UIView!
    @IBOutlet weak var lblHeadingCity: UILabel!
    @IBOutlet weak var txtFieldCity: EthosTextField!
    @IBOutlet weak var viewCity: UIView!
    @IBOutlet weak var superViewCity: UIView!
    @IBOutlet weak var lblHeadingMessage: UILabel!
    @IBOutlet weak var txtViewMessage: UITextView!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var superViewMessage: UIView!
    @IBOutlet weak var lblHeadingBrandLooking: UILabel!
    @IBOutlet weak var txtFieldBrandLooking: EthosTextField!
    @IBOutlet weak var viewBrandLooking: UIView!
    @IBOutlet weak var superViewBrandLooking: UIView!
    @IBOutlet weak var lblHeadingModelLooking: UILabel!
    @IBOutlet weak var txtFieldModelLooking: EthosTextField!
    @IBOutlet weak var viewModelLooking: UIView!
    @IBOutlet weak var superViewModelLooking: UIView!
    @IBOutlet weak var btnGetAQuote: UIButton!
    @IBOutlet weak var btnImageUpload: UIButton!
    @IBOutlet weak var btnLabelUpload: UIButton!
    @IBOutlet weak var btnLblDescriptionUpload: UIButton!
    
    @IBOutlet weak var collectionViewImages: UICollectionView!
    
    @IBOutlet weak var constraintHeightImages: NSLayoutConstraint!
    @IBOutlet weak var tableViewBrand: UITableView!
    @IBOutlet weak var tableViewBrandLooking: UITableView!
    @IBOutlet weak var constraintHeightBrand: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightBrandLooking: NSLayoutConstraint!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var arrImages = [UIImage]() {
        didSet {
            if arrImages.count == 0 {
                self.constraintHeightImages.constant = 0
            } else {
                self.constraintHeightImages.constant = 120
            }
            self.collectionViewImages.reloadData()
            self.contentView.layoutIfNeeded()
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.reloadHeightOfTableView])
        }
    }
    
    var delegate : SuperViewDelegate?

    var selectedBrand : FormBrand? {
        didSet {
            if let brand = self.selectedBrand {
                self.txtFieldBrand.text = brand.label
            }
        }
    }
    
    var selectedBrandLooking : FormBrand? {
        didSet {
            if let brand = self.selectedBrandLooking {
                self.txtFieldBrandLooking.text = brand.label
            }
        }
    }
    
    var showBrandTable : Bool = false {
        didSet {
            self.constraintHeightBrand.constant = showBrandTable ? 200 : 0
        }
    }
    
    var showBrandTableLooking : Bool = false {
        didSet {
            self.constraintHeightBrandLooking.constant = showBrandTableLooking ? 200 : 0
        }
    }
    
    let brandViewModel = GetBrandsViewModel()
    var getQuoteViewModel = GetAQuoteViewModel()
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoFillFields()
        self.txtViewMessage.textContainer.lineFragmentPadding = 0
        collectionViewImages.dataSource = self
        collectionViewImages.delegate = self
        getQuoteViewModel.delegate = self
        tableViewBrand.dataSource = self
        tableViewBrand.delegate = self
        tableViewBrandLooking.dataSource = self
        tableViewBrandLooking.delegate = self
        
        collectionViewImages.registerCell(className: ImageCollectionViewCell.self)
        
        tableViewBrand.registerCell(className: HeadingCell.self)
        tableViewBrandLooking.registerCell(className: HeadingCell.self)
        
        tableViewBrand.setBorder(borderWidth: 1, borderColor: EthosColor.appBGColor, radius: 0)
        tableViewBrandLooking.setBorder(borderWidth: 1, borderColor: EthosColor.appBGColor, radius: 0)
        brandViewModel.delegate = self
       
        viewPhoto.setBorder(borderWidth: 1, borderColor: EthosColor.seperatorColor, radius: 0)
        
        txtFieldBrand.initWithUIParameters( placeHolderText: EthosConstants.SelectBrand, rightView: UIImageView(image: UIImage.imageWithName(name: EthosConstants.downArrow)), placeholderColor: .black, underLineColor: .clear, textInset: 0)
        txtFieldModel.initWithUIParameters(placeHolderText: EthosConstants.EnterModel, placeholderColor: .black, underLineColor: .clear, textInset: 0)
        
        txtFieldBrandLooking.initWithUIParameters( placeHolderText: EthosConstants.SelectBrand   , rightView: UIImageView(image: UIImage.imageWithName(name: EthosConstants.downArrow)), placeholderColor: .black, underLineColor: .clear, textInset: 0)
        txtFieldModelLooking.initWithUIParameters(placeHolderText: EthosConstants.EnterModel, placeholderColor: .black, underLineColor: .clear, textInset: 0)
        
        txtFieldName.initWithUIParameters(placeHolderText: EthosConstants.YourFullName, placeholderColor: .black, underLineColor: .clear, textInset: 0)
        txtFieldEmail.initWithUIParameters(placeHolderText: EthosConstants.YourEmailAddress, placeholderColor: .black, underLineColor: .clear, textInset: 0)
        txtFieldPhone.initWithUIParameters(placeHolderText: EthosConstants.YourMobileNumber, placeholderColor: .black, underLineColor: .clear, textInset: 0)
        txtFieldCity.initWithUIParameters(placeHolderText: EthosConstants.SelectYourCity, placeholderColor: .black, underLineColor: .clear, textInset: 0)
        
        txtFieldName.delegate = self
        txtFieldCity.delegate = self
        txtFieldEmail.delegate = self
        txtFieldModel.delegate = self
        txtFieldModelLooking.delegate = self
        txtFieldPhone.delegate = self
        txtViewMessage.delegate = self
        
        self.txtViewMessage.text = EthosConstants.WriteYourMessage
        self.txtViewMessage.textColor = .black
        self.txtViewMessage.font = EthosFont.Brother1816Regular(size: 12)
        
        txtFieldPhone.keyboardType = .numberPad
    }
    
    override func prepareForReuse() {
        constraintHeightBrand.constant = 0
        constraintHeightBrandLooking.constant = 0
    }
    
    func validateFields() -> Bool {
        
        var valid = true
        
        if txtFieldBrand.text?.isBlank ?? true || self.selectedBrand == nil {
            txtFieldBrand.showError(str: "Please select brand")
            valid = false
        } else {
            txtFieldBrand.removeError()
        }
        
        if txtFieldBrandLooking.text?.isBlank ?? true || self.selectedBrandLooking == nil {
            txtFieldBrandLooking.showError(str: "Please select brand")
            valid = false
        } else {
            txtFieldBrandLooking.removeError()
        }
        
        if txtFieldModel.text?.isBlank ?? true  {
            txtFieldModel.showError(str: EthosConstants.PleaseEnterModel)
            valid = false
        } else {
            txtFieldModel.removeError()
        }
        
        if txtFieldModelLooking.text?.isBlank ?? true  {
            txtFieldModelLooking.showError(str: EthosConstants.PleaseEnterModel)
            valid = false
        } else {
            txtFieldModelLooking.removeError()
        }
        
        if txtViewMessage.text?.isBlank ?? true || txtViewMessage.text == EthosConstants.WriteYourMessage {
            txtViewMessage.showBottomError(str: EthosConstants.pleaseEnterMessage)
            valid = false
        } else if txtViewMessage.text.count < 5  {
            txtViewMessage.showBottomError(str: EthosConstants.PleaseEnterAtLeast5Characters)
            valid = false
        } else {
            txtViewMessage.removeBottomError()
        }
        
        if arrImages.count == 0 {
            self.superViewPhoto.shake()
            self.superViewPhoto.showBottomError(str: EthosConstants.PleaseUploadAtLeastOneImage)
            valid = false
        } else {
            self.superViewPhoto.removeBottomError()
        }
        
        if arrImages.count > 3 {
            self.btnImageUpload.shake()
            self.btnImageUpload.showBottomError(str: EthosConstants.maximumImagesMessage)
            valid = false
        }
        
        if !txtFieldName.validateAgainstName() {
            valid = false
        }
        
        if !txtFieldEmail.validateAgainstEmail() {
            valid = false
        }
        
        if !txtFieldPhone.validateAgainstPhoneNumber() {
            valid = false
        }
        
        if !txtFieldCity.validateAgainstCity() {
            valid = false
        }
        
        
        return valid
    }
    
    func autoFillFields() {
        txtFieldName.text = ((Userpreference.firstName ?? "") + " " + (Userpreference.lastName ?? "")).trimmingCharacters(in: .whitespacesAndNewlines)
        txtFieldEmail.text = Userpreference.email
        txtFieldPhone.text = Userpreference.phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines)
        txtFieldCity.text = Userpreference.location?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    @IBAction func btnUploadAction(_ sender: UIButton) {
        if self.arrImages.count < 3 {
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.uploadImageForTradeQuote, EthosKeys.remainedCount : self.arrImages.count])
        } else {
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.showAlert, EthosKeys.alerTitle : EthosConstants.maximumImagesMessage , EthosKeys.alertMessage : ""])
        }
        
    }
    
    @IBAction func didTapCheckBox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnBrandDidTapped(_ sender: UIButton) {
        showBrandTable = !showBrandTable
    }
  
    @IBAction func btnBrandLookingDidTapped(_ sender: UIButton) {
        showBrandTableLooking = !showBrandTableLooking
    }
    
    
    @IBAction func btnGetAQuoteDidTapped(_ sender: UIButton) {
        if validateFields() {
            
            let params : [String : String] =  [
                EthosConstants.name : txtFieldName.text ?? "",
                EthosConstants.email : txtFieldEmail.text ?? "",
                EthosConstants.brandId : selectedBrand?.value ?? "",
                EthosConstants.brandName : selectedBrand?.label ?? "",
                EthosConstants.lookingBrandId : selectedBrandLooking?.value ?? "",
                EthosConstants.lookingBrandName : selectedBrandLooking?.label ?? "",
                EthosConstants.phone : txtFieldPhone.text ?? "",
                EthosConstants.modelNumber : txtFieldModel.text ?? "",
                EthosConstants.lookingModelNumber : txtFieldModelLooking.text ?? "",
                EthosConstants.comment : txtViewMessage.text ?? "",
                EthosConstants.city : txtFieldCity.text ?? "",
                EthosConstants.subscribe : checkBox.isSelected ? "1" : "0"
            ]
            
            getQuoteViewModel.callApiForRequestQuotation(site : .secondMovement, forSell: false, requestBody: params, images: self.arrImages)
            
        }
    }
    
    
    
}

extension GetAQuoteTradeTableViewCell : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brandViewModel.formBrands.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
    case tableViewBrand, tableViewBrandLooking :
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
                
                if tableView == self.tableViewBrand {
                    if selectedBrand?.value == self.brandViewModel.formBrands[safe : indexPath.row]?.value {
                        cell.setHeading(title: brandViewModel.formBrands[safe : indexPath.row]?.label ?? "", textColor: .white, backgroundColor: .black, image: .imageWithName(name: EthosConstants.tick),imageHeight: 10, spacingTitleImage: 10, leading: 10);
                    } else {
                        cell.setHeading(title: brandViewModel.formBrands[safe : indexPath.row]?.label ?? "",textColor: .black, backgroundColor: .white, image: .imageWithName(name: EthosConstants.tick),imageHeight: 10, spacingTitleImage: 10, leading: 10)
                    }
                }
                
                if tableView == self.tableViewBrandLooking {
                    if selectedBrandLooking?.value == self.brandViewModel.formBrands[safe : indexPath.row]?.value {
                        cell.setHeading(title: brandViewModel.formBrands[safe : indexPath.row]?.label ?? "",textColor: .white, backgroundColor: .black, image: .imageWithName(name: EthosConstants.tick),imageHeight: 10, spacingTitleImage: 10, leading: 10);
                    } else {
                        cell.setHeading(title: brandViewModel.formBrands[safe : indexPath.row]?.label ?? "",textColor: .black, backgroundColor: .white, image: .imageWithName(name: EthosConstants.tick),imageHeight: 10, spacingTitleImage: 10, leading: 10)
                    }
                }
                
                return cell
            }
   
    default :
            return UITableViewCell()
    }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableViewBrand {
            self.selectedBrand = brandViewModel.formBrands[safe : indexPath.row]
        }
        if tableView == self.tableViewBrandLooking {
            self.selectedBrandLooking = brandViewModel.formBrands[safe : indexPath.row]
        }
        tableView.reloadData()
        self.showBrandTable = false
        self.showBrandTableLooking = false
    }
    
    
}

extension GetAQuoteTradeTableViewCell : GetBrandsViewModelDelegate {
    func didGetFormBrands(brands: [FormBrand]) {
        DispatchQueue.main.async {
            self.tableViewBrand.reloadData()
            self.tableViewBrandLooking.reloadData()
        }
    }
    
    func didGetBrandsForSellOrTrade(brands: [BrandForSellOrTrade]) {
        DispatchQueue.main.async {
            self.tableViewBrand.reloadData()
            self.tableViewBrandLooking.reloadData()
        }
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
    
    func didGetBrands(brands: [BrandModel]) {
       
    }
    
    func clearFields() {
        DispatchQueue.main.async {
            self.selectedBrand = nil
            self.selectedBrandLooking = nil
            self.arrImages = []
            self.txtFieldName.text = ""
            self.txtFieldEmail.text = ""
            self.txtFieldCity.text = ""
            self.txtFieldPhone.text = ""
            self.txtFieldBrand.text = ""
            self.txtFieldModel.text = ""
            self.txtFieldModelLooking.text = ""
            self.txtFieldBrandLooking.text = ""
            self.txtViewMessage.text = EthosConstants.WriteYourMessage
            self.autoFillFields()
        }
    }
    
    
}

extension GetAQuoteTradeTableViewCell : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCollectionViewCell.self), for: indexPath) as? ImageCollectionViewCell {
            cell.mainImage.contentMode = .scaleAspectFill
            cell.mainImage.image = arrImages[safe : indexPath.row]
            cell.btnCross.isHidden = false
            cell.delegate = self
            cell.index = indexPath.row
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.cellSize(noOfCellsInRow: 3, Height: 120)
    }
    
}

extension GetAQuoteTradeTableViewCell : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        if info?[EthosKeys.key] as? EthosKeys == .removeImage,
           let index = info?[EthosKeys.value] as? Int {
            if arrImages.count > index {
                self.arrImages.remove(at: index)
                self.collectionViewImages.reloadData()
            }
        }
    }
}

extension GetAQuoteTradeTableViewCell : GetAQuoteViewModelDelegate {
    func requestSuccess() {
        clearFields()
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.showAlert, EthosKeys.alerTitle : EthosConstants.requestSuccess, EthosKeys.alertMessage : ""])
    }
    
    func requestFailed() {
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.showAlert, EthosKeys.alerTitle : EthosConstants.requestFailed, EthosKeys.alertMessage : ""])
    }
    
    
}

extension GetAQuoteTradeTableViewCell : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        
        var maxLength = 30
        
        if textField == txtFieldName {
            maxLength = 30
        }
        
        if textField == txtFieldCity {
            maxLength = 30
        }
        
        
        if textField == txtFieldModel {
            maxLength = 50
        }
        
        if textField == txtFieldModelLooking {
            maxLength = 50
        }
        
        if textField == txtFieldEmail {
            maxLength = 50
        }
        
        if textField == txtFieldPhone {
            maxLength = 10
        }
       
    
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxLength
        
    }
    
}

extension GetAQuoteTradeTableViewCell : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 30
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= maxLength
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == EthosConstants.WriteYourMessage {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            self.txtViewMessage.text = EthosConstants.WriteYourMessage
            self.txtViewMessage.textColor = UIColor.black
        }
    }
    
    
}

