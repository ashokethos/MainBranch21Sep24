//
//  GetAQuoteTableViewCell.swift
//  Ethos
//
//  Created by mac on 21/08/23.
//

import UIKit

class GetAQuoteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var imgBulletFirst: UIImageView!
    @IBOutlet weak var imgBulletSecond: UIImageView!
    @IBOutlet weak var lblSubHeadingFirst: UILabel!
    @IBOutlet weak var lblSubHeadingSecond: UILabel!
    @IBOutlet weak var lblCheckBox: UILabel!
    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var txtFieldBrand: EthosTextField!
    @IBOutlet weak var viewBrand: UIView!
    @IBOutlet weak var superViewBrand: UIView!
    @IBOutlet weak var txtFieldModel: EthosTextField!
    @IBOutlet weak var viewModel: UIView!
    @IBOutlet weak var superViewModel: UIView!
    @IBOutlet weak var lblHeadingPhoto: UILabel!
    @IBOutlet weak var viewPhoto: UIView!
    @IBOutlet weak var superViewPhoto: UIView!
    @IBOutlet weak var txtFieldName: EthosTextField!
    @IBOutlet weak var viewName: UIView!
    @IBOutlet weak var superViewName: UIView!
    @IBOutlet weak var txtFieldEmail: EthosTextField!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var superViewEmail: UIView!
    @IBOutlet weak var txtFieldPhone: EthosTextField!
    @IBOutlet weak var viewPhone: UIView!
    @IBOutlet weak var superViewPhone: UIView!
    @IBOutlet weak var txtFieldCity: EthosTextField!
    @IBOutlet weak var viewCity: UIView!
    @IBOutlet weak var superViewCity: UIView!
    @IBOutlet weak var btnGetAQuote: UIButton!
    @IBOutlet weak var btnImageUpload: UIButton!
    @IBOutlet weak var btnLabelUpload: UIButton!
    @IBOutlet weak var btnLblDescriptionUpload: UIButton!
    
    @IBOutlet weak var constraintHeightBrand: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightImages: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewImages: UICollectionView!
    @IBOutlet weak var tableViewBrand: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    var delegate : SuperViewDelegate?
    var getQuoteViewModel = GetAQuoteViewModel()
    let brandViewModel = GetBrandsViewModel()
    
    var arrImages = [UIImage]() {
        didSet {
            if arrImages.count == 0 {
                self.constraintHeightImages.constant = 0
            } else {
                self.constraintHeightImages.constant = 120
            }
            self.collectionViewImages.reloadData()
            self.contentView.layoutIfNeeded()
            self.delegate?.updateView(
                info: [EthosKeys.key : EthosKeys.reloadHeightOfTableView]
            )
        }
    }
    
    var selectedBrand : FormBrand? {
        didSet {
            if let brand = self.selectedBrand {
                self.txtFieldBrand.text = brand.label
            }
        }
    }
    
    var showBrandTable : Bool = false {
        didSet {
            self.constraintHeightBrand.constant = showBrandTable ? 200 : 0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        brandViewModel.delegate = self
        getQuoteViewModel.delegate = self
        collectionViewImages.dataSource = self
        collectionViewImages.delegate = self
        tableViewBrand.dataSource = self
        tableViewBrand.delegate = self
        
        collectionViewImages.registerCell(
            className: ImageCollectionViewCell.self
        )
        tableViewBrand.registerCell(
            className: HeadingCell.self
        )
        tableViewBrand.setBorder(
            borderWidth: 1,
            borderColor: EthosColor.appBGColor,
            radius: 0
        )
        
        
        viewPhoto.setBorder(
            borderWidth: 1,
            borderColor: EthosColor.seperatorColor,
            radius: 0
        )
        
        txtFieldBrand.initWithUIParameters(
            placeHolderText: EthosConstants.SelectBrand,
            rightView: UIImageView(
                image: UIImage.imageWithName(name: EthosConstants.downArrow)),
            placeholderColor: .black,
            underLineColor: .clear,
            textInset: 0
        )
        txtFieldModel.initWithUIParameters(
            placeHolderText: EthosConstants.EnterModel,
            placeholderColor: .black,
            underLineColor: .clear,
            textInset: 0
        )
        txtFieldName.initWithUIParameters(
            placeHolderText: EthosConstants.YourFullName,
            placeholderColor: .black,
            underLineColor: .clear,
            textInset: 0
        )
        txtFieldEmail.initWithUIParameters(
            placeHolderText: EthosConstants.YourEmailAddress,
            placeholderColor: .black,
            underLineColor: .clear,
            textInset: 0
        )
        txtFieldPhone.initWithUIParameters(
            placeHolderText: EthosConstants.YourMobileNumber,
            placeholderColor: .black,
            underLineColor: .clear,
            textInset: 0
        )
        txtFieldCity.initWithUIParameters(
            placeHolderText: EthosConstants.SelectYourCity,
            placeholderColor: .black,
            underLineColor: .clear,
            textInset: 0
        )
        
        autoFillFields()
        
        txtFieldName.delegate = self
        txtFieldCity.delegate = self
        txtFieldEmail.delegate = self
        txtFieldModel.delegate = self
        txtFieldPhone.delegate = self
        
        txtFieldPhone.keyboardType = .numberPad
        
        lblHeading.setAttributedTitleWithProperties(
            title: EthosConstants.GetYourWatchEvaluatedToReceiveQuote,
            font: EthosFont.Brother1816Medium(
                size: 12
            ),
            kern: 1
        )
        
    }
    
    func autoFillFields() {
        txtFieldName.text = (
            (
                Userpreference.firstName ?? ""
            ) + " " + (
                Userpreference.lastName ?? ""
            )
        ).trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        txtFieldEmail.text = Userpreference.email
        txtFieldPhone.text = Userpreference.phoneNumber?.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        txtFieldCity.text = Userpreference.location?.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }
    
    override func prepareForReuse() {
        constraintHeightBrand.constant = 0
        
    }
    
    func validateFields() -> Bool {
        
        var valid = true
        
        if txtFieldBrand.text?.isEmpty ?? true || self.selectedBrand == nil {
            txtFieldBrand.showError(
                str: "Please select brand"
            )
            valid = false
        } else {
            txtFieldBrand.removeError()
        }
        
        if txtFieldModel.text?.isBlank ?? true  {
            txtFieldModel.showError(
                str: EthosConstants.PleaseEnterModel
            )
            valid = false
        } else {
            txtFieldModel.removeError()
        }
        
        if arrImages.count == 0 {
            self.superViewPhoto.shake()
            self.superViewPhoto.showBottomError(
                str: EthosConstants.PleaseUploadAtLeastOneImage
            )
            valid = false
        } else {
            self.superViewPhoto.removeBottomError()
        }
        
        if arrImages.count > 3 {
            self.btnImageUpload.shake()
            self.btnImageUpload.showBottomError(
                str: EthosConstants.maximumImagesMessage
            )
            valid = false
        }
        
        if txtFieldName.validateAgainstName() == false {
            valid = false
        }
        
        if txtFieldEmail.validateAgainstEmail() == false {
            valid = false
        }
        
        if txtFieldPhone.validateAgainstPhoneNumber() == false {
            valid = false
        }
        
        if txtFieldCity.validateAgainstCity() == false {
            valid = false
        }
        
        
        return valid
    }
    
    
    @IBAction func btnUploadAction(
        _ sender: UIButton
    ) {
        if self.arrImages.count < 3 {
            self.delegate?.updateView(
                info: [
                    EthosKeys.key : EthosKeys.uploadImageForSellQuote,
                    EthosKeys.remainedCount : self.arrImages.count
                ]
            )
        } else {
            self.delegate?.updateView(
                info: [
                    EthosKeys.key : EthosKeys.showAlert,
                    EthosKeys.alerTitle : EthosConstants.maximumImagesMessage ,
                    EthosKeys.alertMessage : ""
                ]
            )
        }
    }
    
    @IBAction func didTapCheckBox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnBrandDidTapped(_ sender: UIButton) {
        showBrandTable = !showBrandTable
    }
    
    @IBAction func didTapOnView(_ sender: UITapGestureRecognizer) {
        self.showBrandTable = false
    }
    
    @IBAction func btnGetAQuoteDidTapped(_ sender: UIButton) {
        if validateFields() {
            let params : [String : String] =  [
                EthosConstants.name : txtFieldName.text ?? "",
                EthosConstants.email : txtFieldEmail.text ?? "",
                EthosConstants.brandId : selectedBrand?.value ?? "",
                EthosConstants.brandName : selectedBrand?.label ?? "",
                EthosConstants.phone : txtFieldPhone.text ?? "",
                EthosConstants.modelNumber : txtFieldModel.text ?? "",
                EthosConstants.city : txtFieldCity.text ?? "",
                EthosConstants.subscribe : checkBox.isSelected ? "1" : "0"
            ]
            
            getQuoteViewModel.callApiForRequestQuotation(
                site: .secondMovement,
                forSell: true,
                requestBody: params,
                images: self.arrImages
            )
        }
    }
}


extension GetAQuoteTableViewCell : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brandViewModel.formBrands.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
    case tableViewBrand :
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
                
                if tableView == self.tableViewBrand {
                    if selectedBrand?.value == self.brandViewModel.formBrands[safe : indexPath.row]?.value {
                        cell.setHeading(
                            title: brandViewModel.formBrands[safe : indexPath.row]?.label ?? "",
                            textColor: .white,
                            backgroundColor: .black,
                            image: .imageWithName(
                                name: EthosConstants.tick
                            ),
                            imageHeight: 10,
                            spacingTitleImage: 10,
                            leading: 10
                        );
                    } else {
                        cell.setHeading(
                            title: brandViewModel.formBrands[safe : indexPath.row]?.label ?? "",
                            textColor: .black,
                            backgroundColor: .white,
                            image: .imageWithName(
                                name: EthosConstants.tick
                            ),
                            imageHeight: 10,
                            spacingTitleImage: 10,
                            leading: 10
                        )
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
        self.selectedBrand = brandViewModel.formBrands[safe : indexPath.row]
        self.tableViewBrand.reloadData()
        self.showBrandTable = false
    }
    
    
}



extension GetAQuoteTableViewCell : GetBrandsViewModelDelegate {
    func didGetFormBrands(brands: [FormBrand]) {
        DispatchQueue.main.async {
            self.tableViewBrand.reloadData()
        }
    }
    
    func didGetBrandsForSellOrTrade(brands: [BrandForSellOrTrade]) {
        DispatchQueue.main.async {
            self.tableViewBrand.reloadData()
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
            self.txtFieldName.text = ""
            self.txtFieldEmail.text = ""
            self.arrImages = []
            self.txtFieldCity.text = ""
            self.txtFieldPhone.text = ""
            self.txtFieldBrand.text = ""
            self.txtFieldModel.text = ""
            self.autoFillFields()
        }
    }
    
}

extension GetAQuoteTableViewCell : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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

extension GetAQuoteTableViewCell : SuperViewDelegate {
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

extension GetAQuoteTableViewCell : GetAQuoteViewModelDelegate {
    func requestSuccess() {
        clearFields()
        self.delegate?.updateView(
            info: [
                EthosKeys.key : EthosKeys.showAlert,
                EthosKeys.alerTitle : EthosConstants.requestSuccess ,
                EthosKeys.alertMessage : ""
            ]
        )
    }
    
    func requestFailed() {
        self.delegate?.updateView(
            info: [
                EthosKeys.key : EthosKeys.showAlert,
                EthosKeys.alerTitle : EthosConstants.requestFailed ,
                EthosKeys.alertMessage : ""
            ]
        )
    }
    
    
}

extension GetAQuoteTableViewCell : UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
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
