//
//  BoutiqueImagesTableViewCell.swift
//  Ethos
//
//  Created by mac on 23/02/24.
//

import UIKit
import CoreLocation
import MapKit
import WebKit
import SafariServices
import Mixpanel

class BoutiqueImagesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerRequestACallback: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionViewImages: UICollectionView!
    @IBOutlet weak var btnPhone: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnMail: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var tf1: EthosTextField!
    @IBOutlet weak var tf2: EthosTextField!
    @IBOutlet weak var tf3: EthosTextField!
    @IBOutlet weak var tf4: EthosTextField!
    
    @IBOutlet weak var imgBlackTriangle: UIImageView!
    @IBOutlet weak var ViewTimings: UIView!
    @IBOutlet weak var lblStoreName: UILabel!
    @IBOutlet weak var lblStoreAddress: UILabel!
    @IBOutlet weak var btnStoreTiming: UIButton!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var btnDownArrow: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var email : String?
    var forSpecialBoutique = false
    var phoneNumbers = [String]()
    var storeTiming = [StoreTiming]()
    var delegate : SuperViewDelegate?
    var superTableView : UITableView?
    var superViewController : UIViewController?
    var viewModel = RequestACallBackViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoFillFields()
        tf1.delegate = self
        tf2.delegate = self
        tf3.delegate = self
        tf4.delegate = self
        setTextFields()
        self.collectionViewImages.registerCell(className: BoutiqueImageCollectionViewCell.self)
        
        self.collectionViewImages.dataSource = self
       
        self.collectionViewImages.delegate = self
        pageControl.preferredIndicatorImage = UIImage(named : "storyControlUnselected")
        ViewTimings.isHidden = true
        imgBlackTriangle.isHidden = true
      
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideTimings))
        self.contentView.addGestureRecognizer(tapGesture)
        self.ViewTimings.setBorder(borderWidth: 0, borderColor: .clear, radius: 5)
        self.btnStoreTiming.isHidden = false
        self.btnDownArrow.isHidden = false
        self.btnPhone.isHidden = false
        self.viewModel.delegate = self
    }
    
    func autoFillFields() {
        tf1.text = ((Userpreference.firstName ?? "") + " " + (Userpreference.lastName ?? "")).trimmingCharacters(in: .whitespacesAndNewlines)
        tf2.text = Userpreference.email
        tf3.text = Userpreference.phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines)
        tf4.text = Userpreference.location?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    override func prepareForReuse() {
        self.pageControl.numberOfPages = 0
        collectionViewImages.reloadData()
        ViewTimings.isHidden = true
        imgBlackTriangle.isHidden = true
        btnStoreTiming.isHidden = false
        btnDownArrow.isHidden = false
        self.btnPhone.isHidden = false
    }
    
    @objc func hideTimings() {
        self.ViewTimings.isHidden = true
        self.imgBlackTriangle.isHidden = true
        self.contentView.endEditing(true)
    }
    
    var store : Store? {
        didSet {
            self.lblStoreName.setAttributedTitleWithProperties(title: store?.storeName ?? "", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24), kern: 0.1)
            
            if var address = store?.storeAddress, self.forSpecialBoutique == false {
                let storeCity = store?.storeCity ?? ""
                let storePincode = store?.storePostalcode ?? ""
                let storeState = store?.storeState ?? ""
                
                var suffix = storeCity + ", " + storeState + " - " + storePincode
                
                if storeCity == ""{
                    if storeState == ""{
                        suffix = storePincode
                    }else{
                        suffix = storeState + " - " + storePincode
                    }
                }
                
                if storeState == ""{
                    suffix = storePincode
                }
                
                address = address + " " + suffix
                
                if address.last == "," {
                    address.removeLast()
                }
                
//                let storePincode = store?.storePostalcode ?? ""
//                let storeState = store?.storeState ?? ""
//                
//                let suffix = storeState + " - " + storePincode
//                
//                address = address + " " + suffix
//                
//                if address.last == "," {
//                    address.removeLast()
//                }
                
                self.lblStoreAddress.setAttributedTitleWithProperties(
                    title: address,
                    font: EthosFont.Brother1816Regular(size: 12),
                    lineHeightMultiple: 1.25,
                    kern: 0.1
                )
                
            } else if var address = store?.storeAddress, self.forSpecialBoutique == true {
                let storeCity = store?.storeCity ?? ""
                let storePincode = store?.storePostalcode ?? ""
                let storeState = store?.storeState ?? ""
                
                var suffix = storeCity + ", " + storeState + " - " + storePincode
                
                if storeCity == ""{
                    if storeState == ""{
                        suffix = storePincode
                    }else{
                        suffix = storeState + " - " + storePincode
                    }
                }
                
                if storeState == ""{
                    suffix = storePincode
                }
                
                address = address + " " + suffix
                
                if address.last == "-" {
                    address.removeLast()
                }else if address.last == "," {
                    address.removeLast()
                }
                self.lblStoreAddress.setAttributedTitleWithProperties(
                    title: address,
                    font: EthosFont.Brother1816Regular(size: 12),
                    lineHeightMultiple: 1.25,
                    kern: 0.1
                )
            }
            
            self.pageControl.numberOfPages = self.store?.gallery?.count ?? 0
            
            let str = self.store?.storeWorkinghour?.htmlToString ?? ""
            
            self.txtView.setAttributedTitleWithProperties(title: str.trimmingCharacters(in: .whitespacesAndNewlines), font: EthosFont.Brother1816Regular(size: 12), alignment: .left, foregroundColor: .white, backgroundColor: .clear, lineHeightMultiple: 1.8, kern: 0.5)
            
            let timings = str.components(separatedBy: .newlines)
            
            let actualTiming = timings.filter { timing in
                timing != "" && timing != "\n" && timing != " "
            }
            var timingsArr = [StoreTiming]()
            for timing in actualTiming {
                let storeTiming = StoreTiming(string: timing)
                timingsArr.append(storeTiming)
            }
            
            self.storeTiming = timingsArr
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "cccc"
            let today = dateFormatter.string(from: Date())
            
            var foundADay = false
            for timing in timingsArr {
                if timing.day?.lowercased() == today.lowercased(),
                   let startTime = timing.startTime,
                   let endTime = timing.endTime {
                    var startT: String?
                    var endT: String?
                    if startTime.uppercased().contains("AM") {
                        startT = timing.startTime?.replacingOccurrences(of: "AM", with: " AM")
                    }else if startTime.uppercased().contains("PM"){
                        startT = timing.startTime?.replacingOccurrences(of: "PM", with: " PM")
                    }
                    
                    if endTime.uppercased().contains("AM") {
                        endT = timing.endTime?.replacingOccurrences(of: "AM", with: " AM")
                    }else if endTime.uppercased().contains("PM"){
                        endT = timing.endTime?.replacingOccurrences(of: "PM", with: " PM")
                    }
                    foundADay = true
                    if checkIfCurrentTimeIsBetween(startTime: startT ?? "", endTime: endT ?? "") {
                        let attributedTitle = NSMutableAttributedString(string: "Open Now - " , attributes: [ NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 12), NSAttributedString.Key.foregroundColor : EthosColor.green, NSAttributedString.Key.kern : 0.5])
                        let attributedTitleStartEnd = NSMutableAttributedString(string: "\(startT ?? "") - \(endT ?? "") (Today)" , attributes: [ NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 12), NSAttributedString.Key.foregroundColor : EthosColor.darkGrey, NSAttributedString.Key.kern : 0.5])
                        attributedTitle.append(attributedTitleStartEnd)
                        self.btnStoreTiming.setAttributedTitle(attributedTitle, for: .normal)
                    } else {
                        let attributedTitle = NSMutableAttributedString(string: "Close Now - " , attributes: [ NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 12), NSAttributedString.Key.foregroundColor : EthosColor.red, NSAttributedString.Key.kern : 0.5])
                        let attributedTitleStartEnd = NSMutableAttributedString(string: "\(startT ?? "") - \(endT ?? "") (Today)" , attributes: [ NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 12), NSAttributedString.Key.foregroundColor : EthosColor.darkGrey, NSAttributedString.Key.kern : 0.5])
                        attributedTitle.append(NSAttributedString(string: "   "))
                        attributedTitle.append(attributedTitleStartEnd)
                        self.btnStoreTiming.setAttributedTitle(attributedTitle, for: .normal)
                    }
                }
            }
            
            if foundADay == false {
                if timingsArr.count >= 1 {
                    if let startTime = timingsArr.first?.startTime,
                       let endTime = timingsArr.first?.endTime {
                        var startT: String?
                        var endT: String?
                        if startTime.uppercased().contains("AM") {
                            startT = timingsArr.first?.startTime?.replacingOccurrences(of: "AM", with: " AM")
                        }else if startTime.uppercased().contains("PM"){
                            startT = timingsArr.first?.startTime?.replacingOccurrences(of: "PM", with: " PM")
                        }
                        
                        if endTime.uppercased().contains("AM") {
                            endT = timingsArr.first?.endTime?.replacingOccurrences(of: "AM", with: " AM")
                        }else if endTime.uppercased().contains("PM"){
                            endT = timingsArr.first?.endTime?.replacingOccurrences(of: "PM", with: " PM")
                        }
                        foundADay = true
                        if checkIfCurrentTimeIsBetween(startTime: startT ?? "", endTime: endT ?? "") {
                            let attributedTitle = NSMutableAttributedString(string: "Open Now - " , attributes: [ NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 12), NSAttributedString.Key.foregroundColor : EthosColor.green, NSAttributedString.Key.kern : 0.5])
                            let attributedTitleStartEnd = NSMutableAttributedString(string: "\(startT ?? "") - \(endT ?? "") (Today)" , attributes: [ NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 12), NSAttributedString.Key.foregroundColor : EthosColor.darkGrey, NSAttributedString.Key.kern : 0.5])
                            attributedTitle.append(NSAttributedString(string: "   "))
                            attributedTitle.append(attributedTitleStartEnd)
                            self.btnStoreTiming.setAttributedTitle(attributedTitle, for: .normal)
                        } else {
                            let attributedTitle = NSMutableAttributedString(string: "Close Now - " , attributes: [ NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 12), NSAttributedString.Key.foregroundColor : EthosColor.red, NSAttributedString.Key.kern : 0.5])
                            let attributedTitleStartEnd = NSMutableAttributedString(string: "\(startT ?? "") - \(endT ?? "") (Today)" , attributes: [ NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 12), NSAttributedString.Key.foregroundColor : EthosColor.darkGrey, NSAttributedString.Key.kern : 0.5])
                            attributedTitle.append(NSAttributedString(string: "   "))
                            attributedTitle.append(attributedTitleStartEnd)
                            self.btnStoreTiming.setAttributedTitle(attributedTitle, for: .normal)
                        }
                    }
                }
            }
            
            if str == "" {
                self.btnStoreTiming.isHidden = true
                self.btnDownArrow.isHidden = true
            } else if btnStoreTiming.titleLabel?.attributedText == nil || btnStoreTiming.titleLabel?.attributedText?.string == "" {
                
                let attrStr = NSMutableAttributedString(string: str , attributes: [ NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 12), NSAttributedString.Key.foregroundColor : EthosColor.darkGrey, NSAttributedString.Key.kern : 0.5])
                
                if str.lowercased().contains("24/7") || str.lowercased().contains("24*7") {
                    let attributedTitle = NSMutableAttributedString(string: "Open " , attributes: [ NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 12), NSAttributedString.Key.foregroundColor : EthosColor.red, NSAttributedString.Key.kern : 0.5])
                    attributedTitle.append(attrStr)
                    self.btnStoreTiming.setAttributedTitle(attributedTitle, for: .normal)
                } else {
                    self.btnStoreTiming.setAttributedTitle(attrStr, for: .normal)
                }
                
            }
            
            if let phoneNumber = store?.storePhone {
                
                let headPhoneNumbers = store?.storeHeadphone?.components(separatedBy: "|") ?? []
                
                let phoneNumbers = phoneNumber.components(separatedBy: "|")
                var arrPhoneNumber = [String]()
                for number in phoneNumbers {
                    if number != " " || number != "" || number != "\n" {
                        arrPhoneNumber.append(number.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
                
                for number in headPhoneNumbers {
                    if number != " " || number != "" || number != "\n" {
                        arrPhoneNumber.append(number.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
                
                self.phoneNumbers = arrPhoneNumber
                
                if arrPhoneNumber.count == 0 {
                    self.btnPhone.isHidden = true
                } else {
                    self.btnPhone.isHidden = false
                }
            }
            
            if let mailId = store?.storeEmail, mailId.isValidEmail {
                self.email = mailId
            }
        }
    }
    
    func clearFields() {
        self.tf1.text = ""
        self.tf2.text = ""
        self.tf3.text = ""
        self.tf4.text = ""
        autoFillFields()
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
    
    func checkIfCurrentTimeIsBetween(startTime: String, endTime: String) -> Bool {
        guard let start = Formatter.today.date(from: startTime),
              let end = Formatter.today.date(from: endTime) else {
            return false
        }
        return DateInterval(start: start, end: end).contains(Date())
    }
    
    func setTextFields() {
        tf1.initWithUIParameters(placeHolderText: "Full Name*", textColor: .black, leftView: nil, rightView: nil, placeholderColor: .black, underLineColor: .clear, errUnderLineColor: EthosColor.red, errTextColor: EthosColor.red, errImage: nil, leftViewHeight: 0, leftViewWidth: 0, rightViewWidth: 0, rightViewHeight: 0, textInset: 0)
        
        tf2.initWithUIParameters(placeHolderText: "Email Address*", textColor: .black, leftView: nil, rightView: nil, placeholderColor: .black, underLineColor: .clear, errUnderLineColor: EthosColor.red, errTextColor: EthosColor.red, errImage: nil, leftViewHeight: 0, leftViewWidth: 0, rightViewWidth: 0, rightViewHeight: 0, textInset: 0)
        
        tf3.initWithUIParameters(placeHolderText: "Phone No*", textColor: .black, leftView: nil, rightView: nil, placeholderColor: .black, underLineColor: .clear, errUnderLineColor: EthosColor.red, errTextColor: EthosColor.red, errImage: nil, leftViewHeight: 0, leftViewWidth: 0, rightViewWidth: 0, rightViewHeight: 0, textInset: 0)
        
        tf4.initWithUIParameters(placeHolderText: "City*", textColor: .black, leftView: nil, rightView: nil, placeholderColor: .black, underLineColor: .clear, errUnderLineColor: EthosColor.red, errTextColor: EthosColor.red, errImage: nil, leftViewHeight: 0, leftViewWidth: 0, rightViewWidth: 0, rightViewHeight: 0, textInset: 0)
    }
    
    @IBAction func btnStoreTimingDidTapped(_ sender: UIButton) {
        ViewTimings.isHidden = !ViewTimings.isHidden
        imgBlackTriangle.isHidden = !imgBlackTriangle.isHidden
    }
    
    
    @IBAction func btnPhoneDidTapped(_ sender: UIButton) {
        self.hideTimings()
        if let vc = self.superViewController?.storyboard?.instantiateViewController(withIdentifier: String(describing: EthosBottomSheetTableViewController.self)) as? EthosBottomSheetTableViewController {
            vc.delegate = self
            vc.data = self.phoneNumbers
            vc.key = .forPhoneNumber
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            vc.superController = self.superViewController
            self.superViewController?.present(vc, animated: true)
        }
    }
    
    @IBAction func btnShare(_ sender: UIButton) {
        self.hideTimings()
        openMapForPlace()
    }
    
    @IBAction func btnEmailDidTapped(_ sender: UIButton) {
        self.hideTimings()
        if let email = self.email, let mailIdUrl = URL(string: "mailto:\(email)") {
            if UIApplication.shared.canOpenURL(mailIdUrl) {
                Mixpanel.mainInstance().trackWithLogs(event: "Connect With Boutique Clicked", properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    "Boutique Code" : self.store?.storeCode,
                    "Boutique Name" : self.store?.storeName,
                    "Connect Option" : "Email"
                ])
                UIApplication.shared.open(mailIdUrl)
            }
        }
    }
    
    @IBAction func btnSubmitDidTapped(_ sender: UIButton) {
        self.hideTimings()
        if validateFields() {
            let params : [String : String] = [
                EthosConstants.name: self.tf1.text ?? "",
                EthosConstants.email: self.tf2.text ?? "",
                EthosConstants.phone: self.tf3.text ?? "",
                EthosConstants.location: self.tf4.text ?? "",
                EthosConstants.city: self.tf4.text ?? "",
                EthosConstants.storeName: self.store?.storeName ?? "",
            ]
            btnSubmit.isEnabled = false
            self.viewModel.callApiForRequestCallBackForStoreDetail(params: params)
        }
    }
    
    func openMapForPlace() {
        if let latitude = store?.storeLatitude,
           let longitude = store?.storeLongitude,
           let lat = Double(latitude),
           let long = Double(longitude) {
            
            let latitude:CLLocationDegrees = lat
            let longitude:CLLocationDegrees =  long
            
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "\(self.store?.storeName ?? "")"
            mapItem.openInMaps(launchOptions: options)
            
            Mixpanel.mainInstance().trackWithLogs(event: "Connect With Boutique Clicked", properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                "Boutique Code" : self.store?.storeCode,
                "Boutique Name" : self.store?.storeName,
                "Connect Option" : "Direction"
            ])
        }
    }
}

extension BoutiqueImagesTableViewCell : UICollectionViewDataSource , UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.store?.gallery?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.item
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: BoutiqueImageCollectionViewCell.self), for: indexPath) as? BoutiqueImageCollectionViewCell {
            if let url = URL(string: (self.store?.imageURLPrefix ?? "") + (self.store?.gallery?[indexPath.item].galleryImg ?? "")) {
                cell.imageViewMain.kf.setImage(with: url)
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension BoutiqueImagesTableViewCell  : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.superTableView?.contentOffset = CGPoint(x: superTableView?.contentOffset.x ?? 0, y: 500)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.superTableView?.contentOffset = CGPoint(x: superTableView?.contentOffset.x ?? 0, y: 250)
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        hideTimings()
        return true
    }
}

extension BoutiqueImagesTableViewCell : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

extension BoutiqueImagesTableViewCell : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        if let phoneNumber = info?[EthosKeys.value] as? String {
            if let numberUrl = URL(string: "tel://\(phoneNumber.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")") {
                if UIApplication.shared.canOpenURL(numberUrl) {
                    Mixpanel.mainInstance().trackWithLogs(event: "Connect With Boutique Clicked", properties: [
                        EthosConstants.Email : Userpreference.email,
                        EthosConstants.UID : Userpreference.userID,
                        EthosConstants.Gender : Userpreference.gender,
                        EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                        EthosConstants.Platform : EthosConstants.IOS,
                        "Boutique Code" : self.store?.storeCode,
                        "Boutique Name" : self.store?.storeName,
                        "Connect Option" : "Phone"
                    ])
                    UIApplication.shared.open(numberUrl)
                }
            }
        }
    }
}

extension BoutiqueImagesTableViewCell : RequestACallBackViewModelDelegate {
    func requestSuccess() {
        DispatchQueue.main.async {
            self.btnSubmit.isEnabled = true
            self.delegate?.updateView(info: [EthosKeys.key: EthosKeys.showAlert, EthosKeys.alerTitle : EthosConstants.requestSuccess , EthosKeys.alertMessage : ""])
            self.clearFields()
        }
    }
    
    func requestFailure() {
        DispatchQueue.main.async {
            self.delegate?.updateView(info: [EthosKeys.key: EthosKeys.showAlert, EthosKeys.alerTitle : EthosConstants.requestFailed , EthosKeys.alertMessage : ""])
        }
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

