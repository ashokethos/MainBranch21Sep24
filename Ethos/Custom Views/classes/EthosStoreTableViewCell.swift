//
//  EthosStoreTableViewCell.swift
//  Ethos
//
//  Created by mac on 09/08/23.
//

import UIKit
import CoreLocation
import MapKit
import Mixpanel

class EthosStoreTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageViewStore: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblStoreAddress: UILabel!
    @IBOutlet weak var btnMobile: UIButton!
    @IBOutlet weak var btnNavigation: UIButton!
    @IBOutlet weak var btnEmail: UIButton!
    var phoneNumbers = [String]()
    
    override func prepareForReuse() {
        self.contentView.hideSkeleton()
        
    }
    
    var store : Store? {
        didSet {
            if let name = store?.storeName {
                self.lblTitle.setAttributedTitleWithProperties(
                    title: name,
                    font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18),
                    foregroundColor: .black,
                    lineHeightMultiple: 1,
                    kern: 0.1
                )
                
            }
            
            if var address = store?.storeAddress {
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
                
                self.lblStoreAddress.setAttributedTitleWithProperties(
                    title: address,
                    font: EthosFont.Brother1816Regular(size: 12),
                    lineHeightMultiple: 1.25,
                    kern: 0.1
                )
                
            }
            
            if let image = store?.image, let url = URL(string: image) {
                self.imageViewStore.kf.setImage(with: url)
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
                    self.btnMobile.isHidden = true
                } else {
                    self.btnMobile.isHidden = false
                }
            }
            self.contentView.layoutIfNeeded()
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
    
    
    @IBAction func btnEmailDidTapped(_ sender: UIButton) {
        if let email = self.store?.storeEmail, let mailIdUrl = URL(string: "mailto:\(email)") {
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
    
    
    
    @IBAction func btnNavigationDidTapped(_ sender: UIButton) {
        openMapForPlace()
    }
    
    @IBAction func btnMobileDidTapped(_ sender: UIButton) {
        if let phoneNumber = self.phoneNumbers.first {
            if let numberUrl = URL(string: "tel://\(phoneNumber.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")") {
                if UIApplication.shared.canOpenURL(numberUrl){
                    UIApplication.shared.open(numberUrl)
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
                }
            }
        }
    }
}

extension EthosStoreTableViewCell : SuperViewDelegate {
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
